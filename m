From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ioctl SIOCSIFADDR minor cleanup
Date: Tue, 15 Nov 2016 22:31:11 -0500 (EST)
Message-ID: <20161115.223111.734917440131578613.davem@davemloft.net>
References: <1479213899-5952-1-git-send-email-cugyly@163.com>
        <20161115.220108.1225196299725031215.davem@davemloft.net>
        <8729016553E3654398EA69218DA29EEF0E42F73A@cnshjmbx02>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cugyly@163.com, netdev@vger.kernel.org
To: Linyu.Yuan@alcatel-sbell.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35822 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752020AbcKPDbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 22:31:12 -0500
In-Reply-To: <8729016553E3654398EA69218DA29EEF0E42F73A@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Date: Wed, 16 Nov 2016 03:13:31 +0000

> So assign label to request name will do same thing as original code.

Nope.  dev->name does not have the colon, it was trimmed from the
string for the device lookup.  So the found device's dev->name does
not have the colon character, even if it was in ifr.ifr_name

This was my entire point.

You are changing the behvaior of the code in an invalid way.
