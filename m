From: Harald Welte <laforge@gnumonks.org>
Subject: Re: ICMPv6 ratelimiting, which /proc-settings related?
Date: Sat, 13 Jul 2002 21:49:19 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020713194919.GQ24779@naboo.lsm>
References: <17380000.1026547066@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Peter Bieringer <pb@bieringer.de>
Content-Disposition: inline
In-Reply-To: <17380000.1026547066@localhost>
List-Id: netdev.vger.kernel.org

On Sat, Jul 13, 2002 at 09:57:46AM +0200, Peter Bieringer wrote:

> extending my IPv6-howto with information about the /proc-FS I found
> that there is no setting for ICMPv6 rate limiting.
> 
> But in "ipv6/icmp.c" there are some " if (net_ratelimit())" calls.
> 
> How can this limit be controlled? Is it the
>         "/proc/sys/net/ipv4/icmp_ratelimit"
> switch?

no, the net_ratelimit() is a generic function to limit the rate of
printk()'s to prevent syslog flooding...

> TIA,
>  Peter

-- 
Live long and prosper
- Harald Welte / laforge@gnumonks.org               http://www.gnumonks.org/
============================================================================
GCS/E/IT d- s-: a-- C+++ UL++++$ P+++ L++++$ E--- W- N++ o? K- w--- O- M- 
V-- PS+ PE-- Y+ PGP++ t++ 5-- !X !R tv-- b+++ DI? !D G+ e* h+ r% y+(*)
