From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ifconfig bug removes aliases
Date: Sat, 13 Mar 2004 12:07:05 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403131204500.1130@u.domain.uli>
References: <20040310212056.GA5661@time.flatmonk.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Aron Griffis <aron@hp.com>
In-Reply-To: <20040310212056.GA5661@time.flatmonk.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 10 Mar 2004, Aron Griffis wrote:

> Hello, here is the sequence:
>
>     ifconfig eth0:1 10.10.10.1 netmask 255.255.0.0
>     ifconfig eth0:2 10.10.10.2 netmask 255.255.0.0
>     ifconfig eth0:1 down
>
> At this point eth0:2 has disappeared also.  It appears that the aliases
> must be on the same subnet for this to occur, and the creation order is
> also important.

	From inet_del_ifa:

/* 1. Deleting primary ifaddr forces deletion all secondaries */

Regards

--
Julian Anastasov <ja@ssi.bg>
