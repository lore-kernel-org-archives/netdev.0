From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 15/15] tc: introduce Flower classifier
Date: Mon, 11 May 2015 17:30:48 +0200
Message-ID: <20150511153047.GA2222@nanopsycho.mtl.com>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
 <1431177038-11555-16-git-send-email-jiri@resnulli.us>
 <55509BC2.2090702@mojatatu.com>
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
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37503 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbbEKPa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 11:30:58 -0400
Received: by widdi4 with SMTP id di4so101026384wid.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 08:30:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55509BC2.2090702@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 11, 2015 at 02:08:34PM CEST, jhs@mojatatu.com wrote:
>On 05/09/15 09:10, Jiri Pirko wrote:
>>This patch introduces a flow-based filter. So far, the very essential
>>packet fields are supported.
>>
>>This patch is only the first step. There is a lot of potential performance
>>improvements possible to implement. Also a lot of features are missing
>>now. They will be addressed in follow-up patches.
>>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>I have a question Jiri: What kind of flower is this? ;->
>Very nice - Glad Dave pushed you to go this direction.
>For a usable classifier that performs reasonably well, i think
>this one is going to look good.
>
>My suggestion is to not add TCA_FLOWER_POLICE attribute.
>Policers can be added via TCA_FLOWER_ACT (which is the modern
>way to do it). Infact i would suggest even in your iproute2
>code, please kill the conditional that tries to parse for
>TCA_FLOWER_POLICE

Hmm, wait. How I should call tcf_exts_init then? Every cls has this POLICE
attr.
