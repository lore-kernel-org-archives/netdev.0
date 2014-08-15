From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 2/2] ipv4: add a sock pointer to dst->output() path.
Date: Fri, 15 Aug 2014 07:10:59 +0200
Message-ID: <20140815051059.GA1923@nanopsycho.orion>
References: <20140415.134916.1941040568700162970.davem@davemloft.net>
 <20140813170243.GA1869@nanopsycho.orion>
 <20140814.151644.1076362729497460962.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, nasa4836@gmail.com, jchapman@katalix.com,
	lucien.xin@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34526 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaHOFLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 01:11:03 -0400
Received: by mail-wi0-f177.google.com with SMTP id ho1so379099wib.4
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 22:11:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140814.151644.1076362729497460962.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 15, 2014 at 12:16:44AM CEST, davem@redhat.com wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 13 Aug 2014 19:02:43 +0200
>
>> The question is, is it the correct way? Or perhaps something like
>> skb->output_sk would serve this better?
>
>Adding members to sk_buff is strongly discouraged, especially when the
>issue here is simply rearranging things, as needed, so that it's easy
>to pass the 'sk' through the call chain.

I feared that. Cooking up a patch. Thanks!
