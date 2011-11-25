From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: RE: [v4 PATCH 2/2] NETFILTER userspace part for target HMARK
Date: Fri, 25 Nov 2011 15:04:53 +0100
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC1641FB1D64@ESESSCMS0356.eemea.ericsson.se>
References: <1322213787-25796-1-git-send-email-hans@schillstrom.com>
 <1322213787-25796-3-git-send-email-hans@schillstrom.com>,<alpine.LNX.2.01.1111251418440.6279@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "kaber@trash.net" <kaber@trash.net>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>,
	Hans Schillstrom <hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1111251418440.6279@frira.zrqbmnf.qr>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>On Friday 2011-11-25 10:36, Hans Schillstrom wrote:
>
>>+Parameters:
>>+For all masks default is all "1:s", to disable a field use mask 0
>>+For IPv6 it's just the last 32 bits that is included in the hash
>
>Why limit IPv6 to 32?

Performance, and the gain of adding another 192 bits to jhash ain't much.
However there is some cases when it hurts, i.e. when you can't mask of an subnet
I'm not sure it it's a problem or not... 

>>diff --git a/include/linux/netfilter/xt_hmark.h b/include/linux/netfilter/xt_hmark.h
[snip]
>
>This file does not match the kernel-side xt_hmark.h.
>Definitions only used within the userspace side should go into libxt_hmark.c
>anyhow.

Oop,s just forgot to copy the file :-)

>>+union ports {
>>+      struct {
>>+              __u16   src;
>>+              __u16   dst;
>>+      } p16;
>>+      __u32   v32;
>>+};
>
>Bad name "ports", big clash potential.

Yes, I'll change that..

Thanks
Hans