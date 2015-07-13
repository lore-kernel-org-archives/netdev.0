From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Mon, 13 Jul 2015 09:13:58 -0400
Message-ID: <55A3B996.6090501@mojatatu.com>
References: <1436573411-5021-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:36287 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbbGMNOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 09:14:07 -0400
Received: by ieik3 with SMTP id k3so21654924iei.3
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 06:14:05 -0700 (PDT)
In-Reply-To: <1436573411-5021-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/15 20:10, Alexei Starovoitov wrote:
> TC actions need to check for very unlikely event skb->users != 1,
> otherwise subsequent pskb_may_pull/pskb_expand_head will crash.
> When skb_shared() just drop the packet, since in the middle of actions
> it's too late to call skb_share_check(), since classifiers/actions assume
> the same skb pointer.
>

Alexei,
To add to what Dave said - are the rules specified here:
Documentation/networking/tc-actions-env-rules.txt
insufficient?

cheers,
jamal
