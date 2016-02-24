From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 2/4] net: cls_u32: move TC offload feature bit
 into cls_u32 offload logic
Date: Wed, 24 Feb 2016 08:21:57 -0500
Message-ID: <56CDAE75.3070500@mojatatu.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
 <20160223190256.5970.25013.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35423 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754640AbcBXNV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 08:21:59 -0500
Received: by mail-io0-f173.google.com with SMTP id g203so38010640iof.2
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 05:21:59 -0800 (PST)
In-Reply-To: <20160223190256.5970.25013.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-23 02:02 PM, John Fastabend wrote:
> In the original series drivers would get offload requests for cls_u32
> rules even if the feature bit is disabled. This meant the driver had
> to do a boiler plate check on the feature bit before adding/deleting
> the rule.
>
> This patch lifts the check into the core code and removes it from the
> driver specific case.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
