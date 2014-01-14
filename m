From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 6/7] net_sched: cls: move allocation in ->init to
 generic layer
Date: Tue, 14 Jan 2014 10:56:02 -0800
Message-ID: <CAM_iQpV5-xQwK8=7NhAQAjz+1bGfnS=DR+5RqOsC5JLAsyTMFw@mail.gmail.com>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389312845-10304-7-git-send-email-xiyou.wangcong@gmail.com>
	<52D293A2.2070703@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:36823 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbaANS4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 13:56:03 -0500
Received: by mail-oa0-f44.google.com with SMTP id g12so23122oah.3
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 10:56:02 -0800 (PST)
In-Reply-To: <52D293A2.2070703@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 12, 2014 at 5:07 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 01/09/14 19:14, Cong Wang wrote:
>>
>> Most of the filters need allocation of tp->root in ->init()
>> and free it in ->destroy(), make this generic.
>>
>> Also we could reduce the use of tcf_tree_lock a bit.
>>
>> Cc: Thomas Graf <tgraf@suug.ch>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
>
>
> Hrm. This one worries me a little.
> I dont see how just pre-allocing the private head of the classifier
> magically allows you to get rid of locks. Have you tested against those
> classifiers you changed?
> If those locks are useless - then that is a separate patch to kill
> them (sorry, dont have time to test myself right now).


Yeah, I am not sure either. I will re-think about this locking stuff.
