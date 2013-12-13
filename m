From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v3 2/6] net_sched: act: use standard struct list_head
Date: Fri, 13 Dec 2013 10:48:09 -0800
Message-ID: <CAM_iQpVYkvpEH91y-c9ng4fpB+sayiTXnkkszw1=RosazeFuBA@mail.gmail.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com>
	<1386913673-8210-3-git-send-email-xiyou.wangcong@gmail.com>
	<52AAF8CB.6060006@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35007 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166Ab3LMSsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 13:48:09 -0500
Received: by mail-ob0-f178.google.com with SMTP id uz6so2381231obc.9
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 10:48:09 -0800 (PST)
In-Reply-To: <52AAF8CB.6060006@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 4:08 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 12/13/13 00:47, Cong Wang wrote:
>>
>> Currently actions are chained by a singly linked list,
>> therefore it is a bit hard to add and remove a specific
>> entry. Convert it to struct list_head so that in the
>> latter patch we can remove an action without finding
>> its head.
>>
>
> Looks reasonable - but can you find a more usable noun
> than "head"?
>

My English is not good, I can only find "head" or "list" here,
please suggest other better names?
