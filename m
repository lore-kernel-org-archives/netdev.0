From: Richard Weinberger <richard@nod.at>
Subject: Re: bridge-utils: wrong sysfs path odds
Date: Wed, 25 Nov 2015 23:37:41 +0100
Message-ID: <56563835.7020607@nod.at>
References: <5654FD93.1070706@nod.at> <5654FFCF.2080801@nod.at>
 <20151124163735.6f9ad756@xeon-e3> <56557D8B.8090908@nod.at>
 <CAJk_L2GSvNUGiexawakMHdm+v5ndv=qLXB9TD7xxn7z9c-ZMsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.org>
To: Santiago Garcia Mantinan <manty@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:11949 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422AbbKYWhp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 17:37:45 -0500
In-Reply-To: <CAJk_L2GSvNUGiexawakMHdm+v5ndv=qLXB9TD7xxn7z9c-ZMsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Am 25.11.2015 um 23:30 schrieb Santiago Garcia Mantinan:
> Hi!
> 
>> Ask Debian maintainer to send his patches, I don't go patch hunting.
> 
> 
>     While looking what other distros do I came across this patch:
>     https://pkgs.fedoraproject.org/cgit/bridge-utils.git/tree/bridge-utils-1.5-check-error-returns-from-write-to-sysfs.patch
> 
> 
> Don't know about the fedora guys but at least I did send some patches which include this /bridge addition, and Stephen did even ack it as you can read on:
> http://lists.linuxfoundation.org/pipermail/bridge/2011-May/007646.html

Meanwhile I've found https://git.kernel.org/cgit/linux/kernel/git/shemminger/bridge-utils.git/
It contains some fixes.
So, the problem is that we have fixes but no release which contains these.
Stephen, can you do a maintenance release? Maybe 1.5.1?

Thanks,
//richard
