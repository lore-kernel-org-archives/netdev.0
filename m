From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH RFC 3/7] netfilter: add NF_INET_LOCAL_SOCKET_IN chain
 type
Date: Wed, 30 Sep 2015 09:40:19 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1509300938060.9960@nerf40.vanv.qr>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org> <1443525140-13493-4-git-send-email-daniel@zonque.org> <20150929211959.GF19923@breakpoint.cc> <560B8E25.7050801@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Florian Westphal <fw@strlen.de>, pablo@netfilter.org,
	daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, balazs.scheidler@balabit.com
To: Daniel Mack <daniel@zonque.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <560B8E25.7050801@zonque.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2015-09-30 09:24, Daniel Mack wrote:
>
>> Drop?  Makes no sense, else application would not be running in the first
>> place.
>
>Of course you can drop certain packets at this point, depending on other
>details. Say, for instance, you want to match all packets that are
>received by a certain task [...]
>Another use case is accounting. If you want to know how much traffic a
>certain service or application in your system has caused

But the sk info would be available in INPUT already, would it not?
