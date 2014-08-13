From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] cbq: incorrectly low bandwidth setting blocks
 limited traffic
Date: Wed, 13 Aug 2014 07:50:51 -0700
Message-ID: <1407941451.6804.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1407918877.git.vvs@openvz.org>
	 <53EB5C3A.1040206@parallels.com> <53EB5DE8.7030302@cogentembedded.com>
	 <53EB5FFE.1070604@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Vasily Averin <vvs@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:55351 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbaHMOuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 10:50:55 -0400
Received: by mail-pd0-f175.google.com with SMTP id r10so14550518pdi.20
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 07:50:55 -0700 (PDT)
In-Reply-To: <53EB5FFE.1070604@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-08-13 at 16:54 +0400, Vasily Averin wrote:
> On 08/13/2014 04:45 PM, Sergei Shtylyov wrote:
> > Hello.
> > 
> > On 8/13/2014 4:38 PM, Vasily Averin wrote:
> > 
> >> Mainstream commit f0f6ee1f70c4eaab9d52cf7d255df4bd89f8d1c2 have side effect:
> > 
> >    Please also specify that commit's summary line in parens.
> cbq: incorrect processing of high limits

So a more useful way to include the information is to add :

Fixes: f0f6ee1f70c4 ("cbq: incorrect processing of high limits")

Because it will help automatic tools to decide if this fix needs to be
backported to old stable kernels.

Thanks.
