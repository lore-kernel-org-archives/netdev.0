From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH 0/2] af_key: fixes for sleeping while atomic
Date: Wed, 05 Mar 2014 17:21:14 -0500
Message-ID: <22489243.QXrM05WUdr@sifl>
References: <20140227151954.GA30946@redhat.com> <1393935984-8733-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:40822 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbaCEWVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 17:21:18 -0500
Received: by mail-qc0-f177.google.com with SMTP id w7so1924835qcr.22
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 14:21:18 -0800 (PST)
In-Reply-To: <1393935984-8733-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, March 04, 2014 01:26:22 PM Nikolay Aleksandrov wrote:
> Hi,
> The first patch takes care of the issue on the af_key side, and the second
> one fixes it on the selinux side (security_xfrm_policy_alloc).
> There're a few lines >80 but they were already long, I'm not sure if
> breaking them above the limit would make them more readable than they
> already are.
> 
> Best regards,
>  Nikolay Aleksandrov
> 
> CC: Paul Moore <paul@paul-moore.com>
> CC: Dave Jones <davej@redhat.com>
> CC: Steffen Klassert <steffen.klassert@secunet.com>
> CC: Fan Du <fan.du@windriver.com>
> CC: David S. Miller <davem@davemloft.net>
> 
> Nikolay Aleksandrov (2):
>   net: af_key: fix sleeping under rcu
>   selinux: add gfp argument to security_xfrm_policy_alloc and fix
>     callers

My apologies, I had hoped to review this today but other bugs got the better 
of me.  This is top of my list for tomorrow.

Thank you for putting this patchset together.

-- 
paul moore
www.paul-moore.com
