From: Patrick McHardy <kaber@trash.net>
Subject: Re: [2.6 patch] do not select NET_CLS
Date: Mon, 21 Nov 2005 17:16:18 +0100
Message-ID: <4381F2D2.5000605@trash.net>
References: <437BBC59.70301@g-house.de> <20051116235813.GS5735@stusta.de> <20051121155955.GW16060@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christian <evil@g-house.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Roman Zippel <zippel@linux-m68k.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932366AbVKUQQn@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20051121155955.GW16060@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> 2.6.15-rc changes NET_CLS to being automatically select'ed when needed.
> 
> This patch confuses users since NET_CLS is a bool, and compiling an 
> additional module that select's NET_CLS causes unresolved symbols since 
> it's not user-visible that adding a module changes the kernel image.
> 
> This patch therefore changes NET_CLS back to the 2.6.14 status quo of 
> being an user-visible option.

I disagree with this patch. NET_CLS enables the infrastructure support
for classifiers. Users generally don't care about infrastructure but
directly usable things, so I'd prefer to have it automatically selected. 
And there are lots of other cases where enabling a module causes changes
in the kernel image. Some examples include some of the netfilter stuff,
the IPsec transforms, NET_CLS_ROUTE4, the ieee80211 stuff, and a lot
more.
