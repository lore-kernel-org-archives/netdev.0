From: "David S. Miller" <davem@redhat.com>
Subject: Re: Deadlock problem with dev->refcnt somewhere in
 netlink/multicast... [PATCH]
Date: Mon, 2 Feb 2004 15:47:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040202154755.311745d1.davem@redhat.com>
References: <OFDBAB37F5.227951E9-ON88256E2E.0080F5BF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@w.ods.org, netdev@oss.sgi.com, jgarzik@pobox.com,
        Alexandre.Cassen@wanadoo.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFDBAB37F5.227951E9-ON88256E2E.0080F5BF@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Feb 2004 16:41:11 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> Below is a patch for the reference count problem you ran into.
> 
> The problem is that the IGMP code was using "IFF_UP" to determine
> if a report should be sent or a timer should be started. But it is not
> necessarily cleared during a destroy_dev.
> 
> The IPv4 code was also missing an ip_mc_down() call added in the
> IPv6 code for a similar case by Jan Oravec.

Applied to both 2.4.x and 2.6.x, thanks David.
