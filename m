From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: MLD maturity in kernel version 2.6.32.60
Date: Mon, 18 Nov 2013 13:23:54 +0100
Message-ID: <528A06DA.6040302@redhat.com>
References: <trinity-825e48d2-0bab-4020-84f0-77800e55f25a-1384777048114@3capp-gmx-bs16>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965Ab3KRMYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 07:24:04 -0500
In-Reply-To: <trinity-825e48d2-0bab-4020-84f0-77800e55f25a-1384777048114@3capp-gmx-bs16>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2013 01:17 PM, Simon Schneider wrote:
>
> Hi,
> in a development project, we started evaluating MLD functionality.
>
> Our development is based on kernel version 2.6.32.60.
>
> We noticed some pretty basic issues:
>
> - With force_mld_version set to 0 (we expect "MLDv2 with MLDv1 fallback"), we saw only MLDv2 messages, the fallback to MLDv1 didn't seem to work, when we sent MLDv1 messages to the unit.
> - With force_mld_version set to 1 (we expect "MLDv1 only mode"), we also saw MLDv2 messages being generated.
>
> Can someone give a general statement about the MLD implementation maturity in kernel 2.6.32.60? Are there known bugs that would explain the above observations?

(cc'ing Hannes)

You might want to try 3.12 kernel, and if needed backport some of these:

   http://www.spinics.net/lists/netdev/msg249262.html

> We need to see whether it makes sense to put further effort in investigating/fixing any MLD related issue we see.
>
> If this is the wrong list to ask this kind of question, please point me to the correct one.
>
> Thanks in advance,
> best regards, Simon Schneider
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
