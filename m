From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] r8169: clean up
Date: Tue, 2 Nov 2004 20:55:03 +0100
Message-ID: <20041102195503.GM19714@rei.reeler.org>
References: <200411021203.25100.jdmason@us.ibm.com> <20041102192746.GB24860@electric-eye.fr.zoreil.com> <200411021347.39047.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200411021347.39047.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > > 0; -       cmd->autoneg = !!(status & TBINwEnable);
> > > +       cmd->autoneg = status & TBINwEnable;
> Silly question, does "!!" not execute a bitwise not twice?  If not, then 
> please forgive my ignorance.

Yes but the result is not the same, the result will be either 1
or 0 if done with !! and yours will result in TBINwEnable or 0.
