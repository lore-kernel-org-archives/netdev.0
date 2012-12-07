From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH rfc] netfilter: two xtables matches
Date: Fri, 7 Dec 2012 12:26:34 -0500
Message-ID: <CA+FuTSduAv4JdzzOE4tVWQCL-00jruPDwcUxuYvPizQkkKrBbg@mail.gmail.com>
References: <1354735339-13402-1-git-send-email-willemb@google.com>
 <CA+FuTSeYvcdtNf7N=POD+RzsE01+WVsub6F_nqbn06RZyoWx8w@mail.gmail.com>
 <alpine.LNX.2.01.1212052100190.30908@nerf07.vanv.qr> <20121206052246.GA2905@1984>
 <CA+FuTSf+fh21koZRJ_ZDsr8yiiwcw2-pJ4uTyS2pOHZGdBM1-w@mail.gmail.com> <20121207132014.GB3019@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jan Engelhardt <jengelh@inai.de>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f180.google.com ([209.85.210.180]:45903 "EHLO
	mail-ia0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755115Ab2LGR1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 12:27:05 -0500
Received: by mail-ia0-f180.google.com with SMTP id t4so1237639iag.39
        for <netdev@vger.kernel.org>; Fri, 07 Dec 2012 09:27:05 -0800 (PST)
In-Reply-To: <20121207132014.GB3019@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 7, 2012 at 8:20 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Thu, Dec 06, 2012 at 04:12:10PM -0500, Willem de Bruijn wrote:
>> On Thu, Dec 6, 2012 at 12:22 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> > On Wed, Dec 05, 2012 at 09:00:36PM +0100, Jan Engelhardt wrote:
>> >> On Wednesday 2012-12-05 20:28, Willem de Bruijn wrote:
>> >>
>> >> >Somehow, the first part of this email went missing. Not critical,
>> >> >but for completeness:
>> >> >
>> >> >These two patches each add an xtables match.
>> >> >
>> >> >The xt_priority match is a straighforward addition in the style of
>> >> >xt_mark, adding the option to filter on one more sk_buff field. I
>> >> >have an immediate application for this. The amount of code (in
>> >> >kernel + userspace) to add a single check proved quite large.
>> >>
>> >> Hm so yeah, can't we just place this in xt_mark.c?
>> >
>> > I don't feel this belongs to xt_mark at all.
>>
>> Do you have other concerns, or can I resubmit as is for merging in a
>> few days if no one raises additional issues?
>
> In nftables we have the 'meta' extension that allows to match all
> skbuff fields (among other things):
>
> http://1984.lsi.us.es/git/nf-next/tree/net/netfilter/nft_meta.c?h=nf_tables8
>
> I think it's the way to go so we stop adding small matches for each
> skbuff field.
>
> I don't mind the name if it's xt_skbuff or xt_meta.

Okay. I'll respin right now with one more field to select the skb field to
match on, as a patch against tree nf-next, and will send that to
netfilter-devel.
