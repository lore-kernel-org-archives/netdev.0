From: Cong Wang <cwang@twopensource.com>
Subject: Re: Why do we prefer skb->priority to tc filters?
Date: Wed, 11 Mar 2015 11:08:44 -0700
Message-ID: <CAHA+R7Os6=uxTAYr=0ZrCKZpySNJ4QoT=mJa5daGJ_0zgD1Y7w@mail.gmail.com>
References: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36683 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbbCKSIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 14:08:45 -0400
Received: by igkb16 with SMTP id b16so42484589igk.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 11:08:44 -0700 (PDT)
In-Reply-To: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 10:34 AM, Cong Wang <cwang@twopensource.com> wrote:
>
> Given that skb->priority can be specified in user-space, doesn't this
> mean some application can always override our rules specified by tc
> filters? I think we should always respect tc filters over any
> application setting.
>

Hmm, on the other hand, skb->priority can be changed in cgroup
too, in this case the current behavior seems correct. :-/ Interesting.
