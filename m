From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next v2 2/2] net_sched: add network namespace support
 for tc actions
Date: Thu, 25 Feb 2016 07:17:06 -0500
Message-ID: <56CEF0C2.4000901@mojatatu.com>
References: <1456185473-25403-1-git-send-email-xiyou.wangcong@gmail.com>
 <1456185473-25403-3-git-send-email-xiyou.wangcong@gmail.com>
 <56CC5B35.4060408@mojatatu.com>
 <CAM_iQpVVe28XUkSfR1OhwMq6mgJVQ_zcPJn+xmLpb_YDy0wsDg@mail.gmail.com>
 <56CDADDB.5070003@mojatatu.com>
 <CAM_iQpWXbEtv6q-Uj9O+-HPDdBkMj27qo0TYXjzGoQm9cGgicQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:36758 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759644AbcBYMRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 07:17:09 -0500
Received: by mail-io0-f172.google.com with SMTP id l127so85721835iof.3
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 04:17:08 -0800 (PST)
In-Reply-To: <CAM_iQpWXbEtv6q-Uj9O+-HPDdBkMj27qo0TYXjzGoQm9cGgicQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-24 12:21 PM, Cong Wang wrote:
> On Wed, Feb 24, 2016 at 5:19 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
[..]
>> Did you mean something else or am i missing the obvious?
>> I am looking at the call sites for tcf_action_destroy():
>> -tc_dump_tfilter() has access to *net
>> -tcf_exts_change() - one level lower it has access to *net; i think you
>> added this to your patch too.
>> -tcf_action_init() has *net.
>
> Well, having net is not enough, we still need net_id to retrieve hinfo,

I thought you could pass a pointer to the net_id from all those call
sites? Anyways, we can worry about that later.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
