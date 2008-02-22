From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Fri, 22 Feb 2008 17:12:20 +0100
Message-ID: <47BEF464.8060307@trash.net>
References: <200801291316.m0TDGivY024953@hera.kernel.org>	 <1203428949.3223.25.camel@shinybook.infradead.org>	 <47BAE13D.4060206@trash.net>	 <1203431447.3223.33.camel@shinybook.infradead.org>	 <47BAEB6C.1030609@trash.net> <1203666762.5771.35.camel@shinybook.infradead.org> <47BEE31D.7020003@trash.net> <47BEEC5C.4060201@netfilter.org> <47BEEDEF.5060503@trash.net> <47BEF36F.1020802@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>, netdev@vger.kernel.org,
	Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com,
	twoerner@redhat.com,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47BEF36F.1020802@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>> Pablo Neira Ayuso wrote:
>>> Patrick McHardy wrote:
>>>> Yes, that was a bug in the lastest release. We need to
>>>> release a 1.4.1 version or something like that, but I'm
>>>> not too familiar with the release process, so I haven't
>>>> done this so far.
>>> I can schedule one for this weekend, just send me an ACK.
>>
>> That would be great. I think we had another issue in 1.4.0 with
>> some header files, but I can't remeber the details.
>>
>> Jan, I recall we talked about this some time ago, do you remember?
> 
> Was it related with kernel 2.4.x compilation?


Yes, I just found the old mail, the error was:

In file included from include/linux/netfilter/nf_nat.h:4,
                  from extensions/libipt_DNAT.c:9:
include/linux/netfilter/nf_conntrack_tuple.h:29: error: syntax error 
before "__be32"


