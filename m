From: Peter Bieringer <pb@bieringer.de>
Subject: Re: ICMPv6 ratelimiting, which /proc-settings related?
Date: Sun, 14 Jul 2002 19:49:09 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <11480000.1026668949@localhost>
References: <17380000.1026547066@localhost>
 <20020713194919.GQ24779@naboo.lsm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>,
   Maillist USAGI-users <usagi-users@linux-ipv6.org>
In-Reply-To: <20020713194919.GQ24779@naboo.lsm>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1



- --On Saturday, July 13, 2002 09:49:19 PM +0200 Harald Welte
<laforge@gnumonks.org> wrote:

>> extending my IPv6-howto with information about the /proc-FS I found
>> that there is no setting for ICMPv6 rate limiting.
>> 
>> But in "ipv6/icmp.c" there are some " if (net_ratelimit())" calls.
>> 
>> How can this limit be controlled? Is it the
>>         "/proc/sys/net/ipv4/icmp_ratelimit"
>> switch?
> 
> no, the net_ratelimit() is a generic function to limit the rate of
> printk()'s to prevent syslog flooding...

Ok.

Are there any plans on the IPv6 roadmap?

I've cross-post to USAGI also, perhaps they are working on such.

TIA,
        Peter
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE9Mbmfe1eqe5WPQi0RAtxiAKDo6Tz75Sbq14S5By2w8jQtPJZEAQCfWuj4
O5Fg84w7EVbU8Ar9ypuDJjg=
=oP9x
-----END PGP SIGNATURE-----
