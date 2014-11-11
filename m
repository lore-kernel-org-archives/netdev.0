From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch net-next 2/2] sched: introduce vlan action
Date: Tue, 11 Nov 2014 15:18:47 -0800
Message-ID: <CAHA+R7P1PM5=TJYRPPrYc_U4AnLvsgQPZr0coTbeijAUGvB9zg@mail.gmail.com>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us>
	<1415700789-9171-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>, willemb@google.com,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	Florian Westphal <fw@strlen.de>, Paul.Durrant@citrix.com,
	Thomas Graf <tgraf@suug.ch>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:49209 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbaKKXSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 18:18:48 -0500
Received: by mail-qg0-f50.google.com with SMTP id a108so7897660qge.23
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 15:18:47 -0800 (PST)
In-Reply-To: <1415700789-9171-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 2:13 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> This tc action allows to work with vlan tagged skbs. Two supported
> sub-actions are header pop and header push.
>

Can we add this to skbedit instead of adding a new action?

I know vlan tag is not exactly the skb metadata, but still seems
fits in skbedit for me.
