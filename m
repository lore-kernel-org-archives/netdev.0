From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 0/6] Fix broken late binding of actions
Date: Sun, 8 May 2016 13:21:02 -0400
Message-ID: <572F757E.4000000@mojatatu.com>
References: <1462727766-28359-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35473 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbcEHRVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 13:21:04 -0400
Received: by mail-io0-f194.google.com with SMTP id u185so19014871iod.2
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 10:21:04 -0700 (PDT)
In-Reply-To: <1462727766-28359-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-08 01:16 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Some actions were broken in allowing for late binding of actions.
> Late binding workflow is as follows:
> a) create an action and provide all necessary parameters for it
> Optionally provide an index or let the kernel give you one.
> Example:
> sudo tc actions add action police rate 1kbit burst 90k drop index 1
>
> b) later on bind to the pre-created action from a filter definition
> by merely specifying the index.
> Example:
> sudo tc filter add dev lo parent ffff: protocol ip prio 8 \
> u32 match ip src 127.0.0.8/32 flowid 1:8 action police index 1

Sorry - will resend with proper subject

cheers,
jamal
