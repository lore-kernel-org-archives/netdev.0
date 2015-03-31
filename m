From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net 2/2] ipmr,ip6mr: call list_del_rcu() when deleting mr
 table from list
Date: Mon, 30 Mar 2015 17:17:06 -0700
Message-ID: <CAHA+R7N=Hoip-SpwsH=9AHt9=Oyp_-NFJaAwkx4speS2QMM6Cg@mail.gmail.com>
References: <1427310345-29829-1-git-send-email-xiyou.wangcong@gmail.com>
	<1427310345-29829-2-git-send-email-xiyou.wangcong@gmail.com>
	<1427314022.3581245.245236665.477D7858@webmail.messagingengine.com>
	<1427314914.3584424.245242065.67DE2EEE@webmail.messagingengine.com>
	<1427317004.3592779.245256885.395A5939@webmail.messagingengine.com>
	<CAHA+R7Mj7BaVKmmt+0TvUb4a3-mTcP=8_-ZJfxRamOHkjCw-sA@mail.gmail.com>
	<1427331669.3644952.245320733.5C7B84E1@webmail.messagingengine.com>
	<1427372619.2762618.245521141.61D660A6@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37378 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477AbbCaARG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 20:17:06 -0400
Received: by igcxg11 with SMTP id xg11so4038403igc.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 17:17:06 -0700 (PDT)
In-Reply-To: <1427372619.2762618.245521141.61D660A6@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 5:23 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> The rest of the locking seems to be fine. So only rcu_read_lock() is
> missing for lockdep correctness.
>

Since DaveM already marks this as "Changes requested", I will:

1) separate patch 1/2 out for net and possibly stable;

2) fold patch 2/2 into a more complete patch including the
rcu_read_lock() you mentioned,
    only for net-next.

Thanks!
