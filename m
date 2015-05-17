From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net-next] netns: make nsid_lock per net
Date: Sun, 17 May 2015 21:53:32 +0200
Message-ID: <5558F1BC.3000402@6wind.com>
References: <1431726452-13111-1-git-send-email-xiyou.wangcong@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36486 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025AbbEQTxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 15:53:36 -0400
Received: by wizk4 with SMTP id k4so54457426wiz.1
        for <netdev@vger.kernel.org>; Sun, 17 May 2015 12:53:35 -0700 (PDT)
In-Reply-To: <1431726452-13111-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/05/2015 23:47, Cong Wang a =C3=A9crit :
> The spinlock is used to protect netns_ids which is per net,
> so there is no need to use a global spinlock.
>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Nice improvement, thanks!

Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
