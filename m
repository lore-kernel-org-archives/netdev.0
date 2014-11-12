From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/2] sched: introduce vlan action
Date: Wed, 12 Nov 2014 08:47:55 +0100
Message-ID: <20141112074755.GA1882@nanopsycho.orion>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us>
 <1415700789-9171-2-git-send-email-jiri@resnulli.us>
 <CAHA+R7P1PM5=TJYRPPrYc_U4AnLvsgQPZr0coTbeijAUGvB9zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>, willemb@google.com,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	Florian Westphal <fw@strlen.de>, Paul.Durrant@citrix.com,
	Thomas Graf <tgraf@suug.ch>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:57313 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbaKLHr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 02:47:58 -0500
Received: by mail-wi0-f173.google.com with SMTP id n3so3941318wiv.12
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 23:47:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAHA+R7P1PM5=TJYRPPrYc_U4AnLvsgQPZr0coTbeijAUGvB9zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 12, 2014 at 12:18:47AM CET, cwang@twopensource.com wrote:
>On Tue, Nov 11, 2014 at 2:13 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> This tc action allows to work with vlan tagged skbs. Two supported
>> sub-actions are header pop and header push.
>>
>
>Can we add this to skbedit instead of adding a new action?
>
>I know vlan tag is not exactly the skb metadata, but still seems
>fits in skbedit for me.

I was thinking about that as well. It seems much clearer to add a new
action.
