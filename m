From: Kevin Wilson <wkevils@gmail.com>
Subject: copy_skb_header() and sk_buff flags (question)
Date: Wed, 22 Aug 2012 07:55:32 +0300
Message-ID: <CAGXs5wVp2bLnwFiuYEg6ZOv0t3DX4PCCgY-EURbs5bySgEqtdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:55712 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab2HVEzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 00:55:33 -0400
Received: by wgbfm10 with SMTP id fm10so5380650wgb.1
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 21:55:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a question if I may, as I cannot understand this point:

I try to understand why in __copy_skb_header() we copy various flags
(like ip_summed,
local_df, pkt_type, priority, ipvs_property, and more. But there are
flags which we do
not copy, like nohdr, or fclone, or peeked.

 Aren't these flags part of the sk_buff header?

regards,
Kevin
