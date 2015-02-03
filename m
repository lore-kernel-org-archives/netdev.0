From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] veth: set iflink to the peer veth
Date: Tue, 03 Feb 2015 17:21:12 +0100
Message-ID: <54D0F578.1070806@6wind.com>
References: <1422978106-4744-1-git-send-email-nicolas.dichtel@6wind.com> <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:44518 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966446AbbBCQVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 11:21:15 -0500
Received: by mail-wg0-f45.google.com with SMTP id x12so45512832wgg.4
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 08:21:14 -0800 (PST)
In-Reply-To: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/02/2015 17:12, Eric Dumazet a =C3=A9crit :
> If I move one veth to another namespace, is iflink still relevant ?
>
>
You're right. ifindex may change.
