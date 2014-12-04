From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ip monitor: Fixed printing timestamp few times
Date: Thu, 4 Dec 2014 23:43:12 +0200
Message-ID: <CAMw6YJ+UC0dEW5AmRPjMAikjdXU8zu4KNnf0LbKWix-Ofro8Xg@mail.gmail.com>
References: <1417389262-25189-1-git-send-email-vadim4j@gmail.com>
	<20141203091338.2d32de2c@urahara>
	<20141203171126.GA7381@angus-think.wlc.globallogic.com>
	<20141203094731.4d310fc5@urahara>
	<20141203174153.GA12034@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:44495 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933106AbaLDVnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 16:43:14 -0500
Received: by mail-wi0-f172.google.com with SMTP id n3so36122568wiv.11
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 13:43:13 -0800 (PST)
In-Reply-To: <20141203174153.GA12034@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Seems that problem is that by default ipmonitor subscribes to the all
RTNL groups except RTMGRP_TC:
    groups = ~RTMGRP_TC;

And I assume that other netlink messages can also cause such
Timestamping w/o event message ...
So I think there should be another way than ~RTMGR_TC, and this big IF
in accept_msg can be removed.

Regards,
Vadim
