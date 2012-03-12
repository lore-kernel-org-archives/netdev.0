From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH v6] Netfilter ring buffer support
Date: Mon, 12 Mar 2012 19:00:55 +0100
Message-ID: <4F5E39D7.60501@nod.at>
References: <1330989588-26833-1-git-send-email-richard@nod.at> <20120308012849.GA9164@1984> <4F5875B5.1090802@nod.at> <20120312130803.GA31865@1984> <4F5DF9B1.6050703@nod.at> <20120312141230.GA32616@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, rostedt@goodmis.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120312141230.GA32616@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12.03.2012 15:12, Pablo Neira Ayuso wrote:
> On Mon, Mar 12, 2012 at 02:27:13PM +0100, Richard Weinberger wrote:
> [...]
>>> Looking at the code, those are included if bridging is enabled.
>>> Otherwise, I'll be happy to take a patch for this.
>>
>> Doesn't NFLOG just pass the packet header to userspace?
>
> It also passes several interesting metainformation regarding the
> packet to user-space as well. And it can be easily extended to add
> more metainformation without breaking backward compatibility.
>
>> How can you derive meta-information like "PHYSIN" and "PHYSOUT" from
>> the packet header?
>
> See nflog_get_physindev and nflog_get_physoutdev in libnetfilter_log.

Oh. This sounds great.

>> Iff NFLOG is able to produce same log string like LOG does I'm fine.
>
> This is a patch yet incomplete for libnetfilter_log:
>
> http://1984.lsi.us.es/git/rlogd/tree/libnflog.patch
>
> It allows you to print in LOG output format. It still need to add
> support for UDP, UDPlite, and so on, but that shouldn't be hard to
> make.
>
> I'd be happy if someone takes it over and finish it.

Okay. I'll take over it.
Stay tuned!

Thanks,
//richard
