From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [RFT] covert br2684 to seq_file
Date: Tue, 2 Sep 2003 12:14:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902191433.GB67783@gaz.sfgoth.com>
References: <20030902104308.08ce3fa4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams <chas@cmf.nrl.navy.mil>, netdev@oss.sgi.com,
   Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030902104308.08ce3fa4.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Convert the /proc/net/atm/br2684 to seq_file interface.
> It builds and runs, but without any real atm hardware the table
> is empty...

FYI - Francios Romieu has patch for converting much of net/atm/*.c to seq_file
which will probably integrated soon (I think they're still working out
some nits w/ Chas; not sure what the status is currently)  You probably should
coordinate any seq_file work in the ATM code with them to avoid any duplicated
effort.

-Mitch
