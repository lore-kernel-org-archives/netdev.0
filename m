From: Willy Tarreau <willy@w.ods.org>
Subject: Re: Deadlock problem with dev->refcnt somewhere in netlink/multicast... [PATCH]
Date: Tue, 3 Feb 2004 07:00:48 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040203060048.GA3531@alpha.home.local>
References: <OFDBAB37F5.227951E9-ON88256E2E.0080F5BF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        jgarzik@pobox.com, Alexandre.Cassen@wanadoo.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFDBAB37F5.227951E9-ON88256E2E.0080F5BF@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

On Mon, Feb 02, 2004 at 04:41:11PM -0700, David Stevens wrote:
> Below is a patch for the reference count problem you ran into.
> 
> The problem is that the IGMP code was using "IFF_UP" to determine
> if a report should be sent or a timer should be started. But it is not
> necessarily cleared during a destroy_dev.
> 
> The IPv4 code was also missing an ip_mc_down() call added in the
> IPv6 code for a similar case by Jan Oravec.

I would never have found this myself !

> The patch is for 2.4.x but also applies to 2.6.x. In-line for
> whitespace-mangled
> viewing and attached for applying.
> 
> Thanks for reporting the problem, Willy, and let me know if you have any
> problems with the patch.

Thanks a lot, I will try ASAP and will report if I still can break it.

Cheers,
Willy
