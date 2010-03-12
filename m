From: Frans Pop <elendil@planet.nl>
Subject: Re: tcpdump broke in 2.6.34-rc1
Date: Fri, 12 Mar 2010 14:23:59 +0100
Message-ID: <201003121424.00868.elendil@planet.nl>
References: <alpine.LSU.2.01.1003120037050.22042@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-To: <alpine.LSU.2.01.1003120037050.22042@obet.zrqbmnf.qr>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> I am currently on 2.6.34-rc1 and found that tcpdump no
> longer works (dies with setsockopt: invalid argument). Bisect-narrowed
> it down to somewhere between

Probably the same as http://lkml.org/lkml/2010/3/9/439, which has an exact 
bisect.

Has a follow-up that it's fixed by
http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=1162563f82b434e3099c9e6c1bbdba846d792f0d

Cheers,
FJP
