From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH net-next] netfilter: xtables make functions local
Date: Sat, 28 Dec 2013 12:31:26 +0100 (CET)
Message-ID: <alpine.LSU.2.11.1312281230300.16819@nerf08.vanv.qr>
References: <20131227120937.702bc383@nehalam.linuxnetplumber.net> <20131228.012129.170537567898112631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: stephen@networkplumber.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131228.012129.170537567898112631.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 2013-12-28 07:21, David Miller wrote:

>From: Stephen Hemminger <stephen@networkplumber.org>
>Date: Fri, 27 Dec 2013 12:09:37 -0800
>
>> A couple of functions only used in x_tables, don't need to be global
>> 
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
>I'll let Pablo pick this up, thanks.

Negative, there is at least one known external modules using these.
