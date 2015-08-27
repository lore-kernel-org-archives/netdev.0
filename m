From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc to
 inappropriate ones
Date: Wed, 26 Aug 2015 17:08:02 -0700
Message-ID: <20150826170802.27eff88c@urahara>
References: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
	<1440628887-3504-5-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35742 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbbH0AIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 20:08:00 -0400
Received: by pacdd16 with SMTP id dd16so3980709pac.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 17:07:57 -0700 (PDT)
In-Reply-To: <1440628887-3504-5-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Aug 2015 15:41:26 -0700
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> Currently there is no check for if a qdisc is appropriate
> to be used as the default qdisc. This causes we get no
> error even we set the default qdisc to an inappropriate one
> but an error will be shown up later. This is not good.
> 
> Also, for qdisc's like HTB, kernel will just crash when
> we use it as default qdisc, because some data structures are
> not even initialized yet before checking opt == NULL, the cleanup
> doing ->reset() or ->destroy() on them will just crash.

Why not fix the buggy one's instead?
