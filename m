From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/3] r8169: clean up
Date: Tue, 2 Nov 2004 22:56:07 +0100
Message-ID: <20041102215607.GA28148@electric-eye.fr.zoreil.com>
References: <200411021203.25100.jdmason@us.ibm.com> <20041102192746.GB24860@electric-eye.fr.zoreil.com> <200411021347.39047.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200411021347.39047.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> Silly question, does "!!" not execute a bitwise not twice?  If not, then 
> please forgive my ignorance.

<coffee alert>
logical not: !
bitwise not: ~
</coffee>

> If so, then it is unnecessary.  But if you want something prettier, how about:
> 
>  cmd->autoneg = (status & TBINwEnable) ? AUTONEG_ENABLE : AUTONEG_DISABLE;

Ok, I take it.

--
Ueimor.
