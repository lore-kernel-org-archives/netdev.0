From: Richard Weinberger <richard@nod.at>
Subject: Re: bridge-utils: wrong sysfs path odds
Date: Wed, 25 Nov 2015 01:24:47 +0100
Message-ID: <5654FFCF.2080801@nod.at>
References: <5654FD93.1070706@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	manty@debian.org
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:11949 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753554AbbKYAYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 19:24:50 -0500
In-Reply-To: <5654FD93.1070706@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 25.11.2015 um 01:15 schrieb Richard Weinberger:
> Hi!
> 
> Today I was hunting down an issue where "brctl stp br0 off"
> always failed on mips64be with n32 userland.
> 
> It turned out that the ioctl(fd, SIOCDEVPRIVATE, &ifr) with BRCTL_SET_BRIDGE_STP_STATE
> returned -EOPNOTSUPP.
> First I thought that this is a plain ABI issue on mips as in old_dev_ioctl()
> the ioctl() argument was 0x1 instead of the expected BRCTL_SET_BRIDGE_STP_STATE (0x14)

Should be 0xe and not 0x14. It is 14 in decimal. :)

Thanks,
//richard
