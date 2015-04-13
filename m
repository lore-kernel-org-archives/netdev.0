From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Mon, 13 Apr 2015 10:28:56 -0400
Message-ID: <552BD2A8.10105@mojatatu.com>
References: <1428535575-7736-1-git-send-email-ast@plumgrid.com>	<1428535575-7736-2-git-send-email-ast@plumgrid.com> <20150408.224404.1913719826015357860.davem@davemloft.net> <5525EC69.1080606@plumgrid.com> <5526593E.4040608@mojatatu.com> <5526B0E0.7060000@plumgrid.com> <5527C6AE.6010301@mojatatu.com> <55285038.3060806@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36168 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbbDMO26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:28:58 -0400
Received: by igblo3 with SMTP id lo3so46993316igb.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 07:28:57 -0700 (PDT)
In-Reply-To: <55285038.3060806@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/15 18:35, Alexei Starovoitov wrote:

>> To your "bugs" comments:
>> - updating csum; earlier i said i was conflicted it being a
>> useful "feature".
>> You are repeating again that it is a bug. It is not.
>> This action is intended to  mirror or redirect packets, period.
>
> without updating skb->csum act_mirred is breaking csum for
> checksum_complete devices.

Ok, could this then be checked for in dev features flags and
only then recomputed?


> True. The program authors may want to know whether the packet is seen
> on ingress or egress and take different actions inside the program,
> but forcing them to _always_ parse the packet differently because of
> it is not acceptable.


Yes, I see your point here as reasonable dilema. But you could add an
API call the user always make that resets and unsets the header?
It would be a single branch failure for egress/stack source.


cheers,
jamal
