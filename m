From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: [Bonding-announce] [PATCH SET][bonding] cleanup
Date: Thu, 25 Sep 2003 12:47:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925164719.GA45241@calma.pair.com>
References: <200309251549.59177.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bonding-devel@lists.sourceforge.net,
        bonding-announce@lists.sourceforge.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
        Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>,
        "Noam, Amir" <amir.noam@intel.com>,
        "Mendelson, Tsippy" <tsippy.mendelson@intel.com>,
        "Noam, Marom" <noam.marom@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Shmulik Hen <shmulik.hen@intel.com>
Content-Disposition: inline
In-Reply-To: <200309251549.59177.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> patch set can be downloaded from:
> http://osdn.dl.sourceforge.net/sourceforge/bonding/bonding-cleanup-2.4.23-pre5.tar.bz2
> 
> This will update the following files:
> 
>         Documentation/networking/bonding.txt
>         Documentation/networking/ifenslave.c
>         drivers/net/bonding/bond_3ad.c
>         drivers/net/bonding/bond_alb.c
>         drivers/net/bonding/bond_alb.h
>         drivers/net/bonding/bonding.h
>         drivers/net/bonding/bond_main.c
>         include/linux/if_bonding.h
> 
> Description:
> patch 1 - ifenslave lite - No more IP settings to slaves, unified 
>           printing format, code re-org and broken to more functions.
> patch 2 - convert all debug prints to use the dprintk macro and 
>           consolidate format of all prints (e.g. "bonding: Error: 
>           ...").
> patch 3 - death of typedef. eliminate bonding_t/slave_t types and 
>           consolidate casting.
> patch 4 - remove dead code, old compatibility stuff and redundant 
>           checks.

I'm a bit concerned about doing some of this stuff in the 2.4 series.  That
compatibility stuff is there for a reason, and was set to be removed in
2.6.  Perhaps we shouldn't be doing stuff this drastic until 2.6 because of
the risk of breaking users.  

Chad
