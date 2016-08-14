From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net v4 7/7] net_sched: allow flushing tc police actions
Date: Sun, 14 Aug 2016 07:05:12 -0400
Message-ID: <386112ca-ff05-7f6d-493d-dcf901311245@mojatatu.com>
References: <1471152902-12444-1-git-send-email-xiyou.wangcong@gmail.com>
 <1471152902-12444-8-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roman Mashak <mrv@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:35394 "EHLO
	mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965042AbcHNLNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 07:13:14 -0400
Received: by mail-qt0-f180.google.com with SMTP id x25so11506624qtx.2
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 04:13:14 -0700 (PDT)
In-Reply-To: <1471152902-12444-8-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-14 01:35 AM, Cong Wang wrote:
> From: Roman Mashak <mrv@mojatatu.com>
>
> The act_police uses its own code to walk the
> action hashtable, which leads to that we could
> not flush standalone tc police actions, so just
> switch to tcf_generic_walker() like other actions.
>
> (Joint work from Roman and Cong.)
>
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
