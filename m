From: kuznet@ms2.inr.ac.ru
Subject: Re: raw ipv6 broken in 2.4.19
Date: Tue, 13 Aug 2002 08:04:40 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208130404.IAA20030@sex.inr.ac.ru>
References: <1029186150.700.39.camel@tux>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: gandalf@wlug.westbo.se (Martin Josefsson)
In-Reply-To: <1029186150.700.39.camel@tux> from "Martin Josefsson" at Aug 12, 2 11:02:29 pm
List-Id: netdev.vger.kernel.org

Hello!

> It seems to be the tulip driver,

Apparently, it corrupts IPv6 packets. I have seen this bug,
it was cured by tuning pci settings in bios setup to be more conservative.
The most intersting thing was that only ICMP IPv6 were corrupted. :-)

> attaching them, the tcpdump looked perfectly normal to me.

I do not think so, packets should have wrong checksum.

Alexey
