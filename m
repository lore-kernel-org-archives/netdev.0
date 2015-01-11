From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 3/3] x_tables: Factor out 16bit aligment ifname_compare()
Date: Sun, 11 Jan 2015 22:30:41 +0100
Message-ID: <54B2EB81.5050604@nod.at>
References: <1421009571-5279-1-git-send-email-richard@nod.at>	 <1421009571-5279-4-git-send-email-richard@nod.at>	 <1421009969.9233.5.camel@perches.com> <54B2E4DD.90200@nod.at> <1421010853.9233.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	john.fastabend@gmail.com, herbert@gondor.apana.org.au,
	vyasevic@redhat.com, jiri@resnulli.us, vfalico@gmail.com,
	therbert@google.com, edumazet@google.com, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, kuznet@ms2.inr.ac.ru, kadlec@blackhole.kfki.hu,
	kaber@trash.net, pablo@netfilter.org, kay@vrfy.org,
	stephen@networkplumber.org
To: Joe Perches <joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1421010853.9233.7.camel@perches.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 11.01.2015 um 22:14 schrieb Joe Perches:
> On Sun, 2015-01-11 at 22:02 +0100, Richard Weinberger wrote:
>> Am 11.01.2015 um 21:59 schrieb Joe Perches:
>>> On Sun, 2015-01-11 at 21:52 +0100, Richard Weinberger wrote:
>>>> arp_tables.c has a 16bit aligment ifname_compare(), factor
>>>> it out to use it for all tables.
> []
>>> Perhaps this would be better as bool ifname_compare
>> Let's discuss the whole concept first
> 
> The concept seems obvious enough

Anyway, I agree with Linus wrt. bool.
https://lkml.org/lkml/2013/8/31/138

Thanks,
//richard
