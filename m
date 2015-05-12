From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 15/15] tc: introduce Flower classifier
Date: Tue, 12 May 2015 13:37:54 +0200
Message-ID: <20150512113753.GB3647@nanopsycho.mtl.com>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
 <1431177038-11555-16-git-send-email-jiri@resnulli.us>
 <55509BC2.2090702@mojatatu.com>
 <20150511153047.GA2222@nanopsycho.mtl.com>
 <5551E4A7.7020800@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:36183 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997AbbELLiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 07:38:01 -0400
Received: by wizk4 with SMTP id k4so148963198wiz.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 04:38:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5551E4A7.7020800@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 12, 2015 at 01:31:51PM CEST, jhs@mojatatu.com wrote:
>On 05/11/15 11:30, Jiri Pirko wrote:
>
>>Hmm, wait. How I should call tcf_exts_init then? Every cls has this POLICE
>>attr.
>
>call it as so:
>tcf_exts_init(&e, TCA_FLOWER_ACT, 0);

Okay. I sen see it now.

Will send v3 in a minute.

Thanks!

>
>I thought Cong had submitted a patch to kill some of this.
>Basically old tc that may still have some policer stuff will
>still continue to use the old syntax but new additions should not
>continue to propagate it.
>In user space you will no longer be able to say "police" without
>the keyword action (look at iproute2 around commit
>863ecb04b4f7bd49fb40e4914ea22096be6db6bf)
>
>cheers,
>jamal
