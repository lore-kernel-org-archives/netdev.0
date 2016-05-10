From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH nf-next,v2] gtp: add initial driver for datapath of GPRS
 Tunneling Protocol (GTP-U)
Date: Tue, 10 May 2016 10:16:33 -0700
Message-ID: <CALx6S34cHSNmC-QLO8QrbktTwvJMpjkOnsQLEq3W4FLBannBRg@mail.gmail.com>
References: <1462748148-17764-1-git-send-email-pablo@netfilter.org>
	<20160510.122735.2275935466949423395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	laforge@gnumonks.org, aschultz@tpip.net, openbsc@lists.osmocom.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35285 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbcEJRQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 13:16:35 -0400
Received: by mail-io0-f179.google.com with SMTP id d62so24141083iof.2
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 10:16:34 -0700 (PDT)
In-Reply-To: <20160510.122735.2275935466949423395.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 10, 2016 at 9:27 AM, David Miller <davem@davemloft.net> wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Mon,  9 May 2016 00:55:48 +0200
>
>> This is an initial implementation of a netdev driver for GTP datapath
>> (GTP-U) v0 and v1, according to the GSM TS 09.60 and 3GPP TS 29.060
>> standards. This tunneling protocol is used to prevent subscribers from
>> accessing mobile carrier core network infrastructure.
>>
>> This implementation requires a GGSN userspace daemon that implements the
>> signaling protocol (GTP-C), such as OpenGGSN [1]. This userspace daemon
>> updates the PDP context database that represents active subscriber
>> sessions through a genetlink interface.
>>
>> For more context on this tunneling protocol, you can check the slides
>> that were presented during the NetDev 1.1 [2].
>>
>> Only IPv4 is supported at this time.
>>

Is there a timeline for adding IPv6 support?

Tom

>> [1] http://git.osmocom.org/openggsn/
>> [2] http://www.netdevconf.org/1.1/proceedings/slides/schultz-welte-osmocom-gtp.pdf
>>
>> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
>> ---
>> v2: Rebase on top of current HEAD to resolve minor conflict with recent PPP
>>     updates in include/uapi/linux/if_link.h so this applies cleanly.
>
> Applied, thanks.
