From: Pau Koning <paukoning@gmail.com>
Subject: Re: [PATCH 1/7] batman-adv: Move soft-interface initialization to ndo_init
Date: Mon, 24 Dec 2012 15:22:44 +0100
Message-ID: <CANiGF9_=svx+W4Rhx8BL1NBv0H1aULeh71sX9YkMeR66OmmimA@mail.gmail.com>
References: <1353715332-4284-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
To: Sven Eckelmann <sven@narfation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:50198 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572Ab2LXO1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2012 09:27:53 -0500
Received: by mail-ob0-f172.google.com with SMTP id za17so6740948obc.31
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2012 06:27:53 -0800 (PST)
In-Reply-To: <1353715332-4284-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 24, 2012 at 1:02 AM, Sven Eckelmann <sven@narfation.org> wrote:
> The initialization of an net_device object should be done in the
> init/constructor function and not from the outside after the register_netdevice
> was done to avoid race conditions.

This patchset seems to be similar. Shouldn't it have been part of
3.8-rc1 or got rejected? Neither of it happened in the last month
