From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] net: core: set qdisc pkt len before tc_classify
Date: Wed, 13 May 2015 06:10:16 -0700
Message-ID: <1431522616.566.136.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431437838-5478-1-git-send-email-fw@strlen.de>
	 <1431440547.566.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150512151646.GB22387@breakpoint.cc>
	 <20150512170322.GA3524@Alexeis-MBP.westell.com>
	 <55532F5A.5070007@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	daniel@iogearbox.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34075 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934368AbbEMNKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 09:10:18 -0400
Received: by pacyx8 with SMTP id yx8so50409480pac.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 06:10:18 -0700 (PDT)
In-Reply-To: <55532F5A.5070007@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 07:02 -0400, Jamal Hadi Salim wrote:

> Alexei, why do you say this option will have overhead?

Well, they want to be able to give nice numbers and ultimately have
a nice bogomips value ;)

About stab on ingress, I never used it, but maybe Jesper or someone else
did.
