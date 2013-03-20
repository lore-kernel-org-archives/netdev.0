From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: check TSU registers ioremap() error
Date: Wed, 20 Mar 2013 22:04:21 +0300
Message-ID: <514A0835.6070104@cogentembedded.com>
References: <201303200241.33137.sergei.shtylyov@cogentembedded.com> <20130320.122352.1542334118729356561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:61716 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753586Ab3CTSDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 14:03:05 -0400
Received: by mail-la0-f52.google.com with SMTP id fs12so3521304lab.11
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 11:03:04 -0700 (PDT)
In-Reply-To: <20130320.122352.1542334118729356561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/20/2013 07:23 PM, David Miller wrote:

> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Date: Wed, 20 Mar 2013 02:41:32 +0300
>
>> One must check the result of ioremap() -- in this case it prevents potential
>> kernel oops when initializing TSU registers further on...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Applied and queued up for -stable.

    Thanks. However, do you really think it's needed in stable? It's 
only error path, after all...

WBR, Sergei
