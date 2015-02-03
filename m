From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/1] cls_api.c: Fix dumping of non-existing actions'
 stats.
Date: Tue, 03 Feb 2015 09:51:44 -0800
Message-ID: <1422985904.907.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150203141059.GA25454@zenon.in.qult.net>
	 <20150203173251.GB6246@zenon.in.qult.net>
	 <CAHA+R7Pq6aUyCzc2HE+b4RU0RfYnM_cLPfRcV3jLmAZ+dFCsxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ignacy =?UTF-8?Q?Gaw=C4=99dzki?=
	<ignacy.gawedzki@green-communications.fr>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36910 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965956AbbBCRvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 12:51:47 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so26068878igb.0
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 09:51:46 -0800 (PST)
In-Reply-To: <CAHA+R7Pq6aUyCzc2HE+b4RU0RfYnM_cLPfRcV3jLmAZ+dFCsxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-03 at 09:39 -0800, Cong Wang wrote:

> Also, please add Fixes: tag.
> 
> Fixes: commit 33be627159913b094bb578e83e9a7fdc66c10208

Or more exactly use this format for Fixes tag :

Fixes: 33be62715991 ("net_sched: act: use standard struct list_head")

(assuming this commit is indeed the one introducing the problem)
