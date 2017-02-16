From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next] liquidio: improve UDP TX performance
Date: Thu, 16 Feb 2017 10:43:41 -0800
Message-ID: <b07e968b-4a8c-7d11-d32f-5d53ca0c9f3f@hpe.com>
References: <20170216183855.GA4125@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hpe.com ([15.241.32.99]:6612 "EHLO
        g9t1613g.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933384AbdBPSno (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 13:43:44 -0500
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com [15.233.44.26])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g9t1613g.houston.hpe.com (Postfix) with ESMTPS id 3257C628DD
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 18:43:43 +0000 (UTC)
In-Reply-To: <20170216183855.GA4125@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/16/2017 10:38 AM, Felix Manlunas wrote:
> From: VSR Burru <veerasenareddy.burru@cavium.com>
>
> Improve UDP TX performance by:
> * reducing the ring size from 2K to 512
> * replacing the numerous streaming DMA allocations for info buffers and
>   gather lists with one large consistent DMA allocation per ring

By how much was UDP TX performance improved?

happy benchmarking,

rick jones
