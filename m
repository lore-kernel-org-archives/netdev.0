From: Shuyu Wei <wsy2220@gmail.com>
Subject: Re: [PATCH] ethernet:arc: Fix racing of TX ring buffer
Date: Sun, 15 May 2016 07:24:01 +0800
Message-ID: <20160514232401.GB2968@debian-dorm>
References: <20160514161602.GA3347@debian-dorm>
 <20160514200356.GA14105@electric-eye.fr.zoreil.com>
 <20160514231044.GA2968@debian-dorm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wxt@rock-chips.com, davem@davemloft.net, heiko@sntech.de,
	linux-rockchip@lists.infradead.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35666 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbcENXYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 19:24:07 -0400
Received: by mail-pa0-f45.google.com with SMTP id iv1so52145496pac.2
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 16:24:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160514231044.GA2968@debian-dorm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, the last two lines is wrong, ignore it.

I mean I intended to ignore one or two packets.
It's just a trade-off for performance, but it
doesn't cause any memory leak.
