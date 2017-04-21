From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH v2 0/3] uapi glibc compat: fix musl libc compatibility
Date: Fri, 21 Apr 2017 15:14:21 +0200
Message-ID: <25477d46-b100-ce87-98d9-8c5e02d409b8@hauke-m.de>
References: <20170418210036.26039-1-hauke@hauke-m.de>
 <20170420.160739.1263793303398330801.davem@davemloft.net>
 <1492719277.8404.16.camel@infradead.org>
 <20170420.163630.313375940241598525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jarod@redhat.com, jogo@openwrt.org, david.heidelberger@ixit.cz,
        maillist-linux@barfooze.de, mikko.rapeli@iki.fi,
        musl@lists.openwall.com
To: David Miller <davem@davemloft.net>, dwmw2@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170420.163630.313375940241598525.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 04/20/2017 10:36 PM, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Thu, 20 Apr 2017 21:14:37 +0100
> 
>> I agree, except I don't think you're going far enough. Those "standard
>> names" you mention... some of this stuff actually depends on __GLIBC__,
>> and *that* isn't right either.
> 
> Yep, that's something that needs correcting.
> 
Should all libc implementations define __GLIBC__ or could we at least
switch the kernel UAPI to !__KERNEL__ here?

Hauke
