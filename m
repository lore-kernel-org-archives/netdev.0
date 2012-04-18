From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fake rtable dst patch applied but kernel keeps panicing
Date: Wed, 18 Apr 2012 12:31:12 +0200
Message-ID: <1334745072.2472.110.camel@edumazet-glaptop>
References: <4F8E9291.9000607@navynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.huangpeng@huawei.com
To: Massimo Cetra <ctrix+debianbugs@navynet.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38861 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362Ab2DRKbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 06:31:16 -0400
Received: by bkcik5 with SMTP id ik5so5319030bkc.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 03:31:14 -0700 (PDT)
In-Reply-To: <4F8E9291.9000607@navynet.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-18 at 12:08 +0200, Massimo Cetra wrote:
> Hi Eric,
> Hi Peter,
> 
> I applied the 1st patch by Peter to a 3.2.14 kernel, compiled, installed 
> and rebooted.
> 
> I have had another panic and i'm attaching the oops as i received it 
> through netcnsole.
> 
> I don't think the patch is enough to prevent the OOPS.
> 
> Can i be helpful in some way ?
> 
> Thanks,
>   Massimo

Seems a different issue, skb->nf_bridge seems to be NULL
