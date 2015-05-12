From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 15/15] tc: introduce Flower classifier
Date: Tue, 12 May 2015 07:31:51 -0400
Message-ID: <5551E4A7.7020800@mojatatu.com>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us> <1431177038-11555-16-git-send-email-jiri@resnulli.us> <55509BC2.2090702@mojatatu.com> <20150511153047.GA2222@nanopsycho.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:35337 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932192AbbELLcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 07:32:03 -0400
Received: by igbyr2 with SMTP id yr2so102101446igb.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 04:32:02 -0700 (PDT)
In-Reply-To: <20150511153047.GA2222@nanopsycho.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/11/15 11:30, Jiri Pirko wrote:

> Hmm, wait. How I should call tcf_exts_init then? Every cls has this POLICE
> attr.

call it as so:
tcf_exts_init(&e, TCA_FLOWER_ACT, 0);

I thought Cong had submitted a patch to kill some of this.
Basically old tc that may still have some policer stuff will
still continue to use the old syntax but new additions should not
continue to propagate it.
In user space you will no longer be able to say "police" without
the keyword action (look at iproute2 around commit 
863ecb04b4f7bd49fb40e4914ea22096be6db6bf)

cheers,
jamal
