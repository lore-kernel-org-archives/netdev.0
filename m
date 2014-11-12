From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 2/2] sched: introduce vlan action
Date: Wed, 12 Nov 2014 08:06:41 -0500
Message-ID: <54635B61.8020403@mojatatu.com>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us> <1415700789-9171-2-git-send-email-jiri@resnulli.us> <CAHA+R7O=_h4HEF01wFacteawVX-2uvMiPjUAExKV6GphSJySzg@mail.gmail.com> <20141112123445.GE1882@nanopsycho.orion> <54635AAC.3080600@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>, willemb@google.com,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	Florian Westphal <fw@strlen.de>, Paul.Durrant@citrix.com,
	Thomas Graf <tgraf@suug.ch>
To: Jiri Pirko <jiri@resnulli.us>, Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:56050 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbaKLNGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 08:06:48 -0500
Received: by mail-ie0-f180.google.com with SMTP id y20so13531658ier.39
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 05:06:47 -0800 (PST)
In-Reply-To: <54635AAC.3080600@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/14 08:03, Jamal Hadi Salim wrote:
> On 11/12/14 07:34, Jiri Pirko wrote:

> It just happens that user space passes it to you in BE already.
> So this works out because skb_vlan_push expects that to be in BE
> as in:
> int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
>

Sorry, meant proto is in BE but vlan is in host order..
(grr.. need to test).

cheers,
jamal
