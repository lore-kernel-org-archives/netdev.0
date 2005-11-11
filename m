From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [IPV4] Fix secondary IP addresses after promotion
Date: Fri, 11 Nov 2005 14:16:55 +0100
Message-ID: <437499C7.7040302@trash.net>
References: <20051104184633.GA16256@skull.piratehaven.org> <436BFE08.6030906@trash.net> <20051105010740.GR23537@postel.suug.ch> <436C090D.5020201@trash.net> <436C34F8.3090903@trash.net> <20051105134636.GS23537@postel.suug.ch> <20051107215022.GH23537@postel.suug.ch> <4370B203.8070501@trash.net> <20051109005658.GL23537@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Brian Pomerantz <bapper@piratehaven.org>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750734AbVKKNRp@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20051109005658.GL23537@postel.suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <kaber@trash.net> 2005-11-08 15:11
>
>>I have a patch to do this, but it needs some debugging, for some
>>unknown reason it crashes sometimes if I remove addresses without
>>specifying the mask.
>  
> Interesting, do you use an iproute2 version with the wildcard
> address deletion fix attached below?

No, its some old debian version. I'm going to try if it makes a
difference, but it needs to be fixed to work (or at least not crash)
with old versions anyway.
