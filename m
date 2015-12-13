From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH ]net: sched/cls_flow.c : allow nfct-* keys work on ingress
 interfaces
Date: Sun, 13 Dec 2015 09:01:42 -0500
Message-ID: <566D7A46.5090008@mojatatu.com>
References: <CADo-kffbKruR9zqCQj2qp4Z8CHzJJCo0sm94VCg2tAS=XbSJqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Igor Gavrilov <i.o.gavrilov@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35517 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbbLMOBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2015 09:01:50 -0500
Received: by mail-ig0-f178.google.com with SMTP id su19so67829497igc.0
        for <netdev@vger.kernel.org>; Sun, 13 Dec 2015 06:01:50 -0800 (PST)
In-Reply-To: <CADo-kffbKruR9zqCQj2qp4Z8CHzJJCo0sm94VCg2tAS=XbSJqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Igor,

On 15-12-11 04:55 AM, Igor Gavrilov wrote:
> Improved CTTUPLE macro with code from sched/act_connmark.c, so it be
> able to get unNATed addresses from nf_conntrack.
>

1) Question: Have you tested the patch or you just cutnpasted
from connmark.c? By inspection the patch looks ok technically
but if you havent tested, please verify it.
2)The macros have indentation issues around
if (ct == NULL) {} else { }
just use the proper indent rules.

3) Please use proper formatting on submitting patches (such as putting
the From at the top etc). Look at:
Maybe you should use git facilities?

If you meet all the above requirements, please resubmit and
add my Acked-by

cheers,
jamal
