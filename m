From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] forcedeth: Stay in NAPI as long as there's work
Date: Wed, 28 Apr 2010 16:56:30 -0700
Message-ID: <h2m65634d661004281656j9f29fc2btdec0d6bcbee20f35@mail.gmail.com>
References: <1272477251.18228.36.camel@Joe-Laptop.home>
	 <20100428111354.49a6ec1a@nehalam> <20100428112528.01277670@nehalam>
	 <20100428.142534.57451492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: shemminger@vyatta.com, joe@perches.com, netdev@vger.kernel.org,
	aabdulla@nvidia.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:6367 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756678Ab0D1X4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 19:56:34 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o3SNuWnn027386
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 16:56:32 -0700
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by wpaz37.hot.corp.google.com with ESMTP id o3SNuUws028078
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 16:56:31 -0700
Received: by pvc21 with SMTP id 21so84313pvc.30
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 16:56:30 -0700 (PDT)
In-Reply-To: <20100428.142534.57451492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 28, 2010 at 2:25 PM, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 28 Apr 2010 11:25:28 -0700
>
>> The following does the same thing without the extra overhead
>> of testing all the registers. It also handles the out of memory
>> case.
>>
>> Compile tested only...
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> Tom can you test this version?
>

Looks good.  406038 tps in my quick test which still is showing the
benefits.  Thanks for cleaning this up Stephen!

Tom
