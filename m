From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 1/4] net: sched: consolidate offload decision in
 cls_u32
Date: Wed, 24 Feb 2016 08:20:21 -0500
Message-ID: <56CDAE15.9000700@mojatatu.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:35826 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbcBXNUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 08:20:23 -0500
Received: by mail-io0-f178.google.com with SMTP id g203so37918837iof.2
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 05:20:23 -0800 (PST)
In-Reply-To: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-23 02:02 PM, John Fastabend wrote:
> The offload decision was originally very basic and tied to if the dev
> implemented the appropriate ndo op hook. The next step is to allow
> the user to more flexibly define if any paticular rule should be
> offloaded or not. In order to have this logic in one function lift
> the current check into a helper routine tc_should_offload().
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
