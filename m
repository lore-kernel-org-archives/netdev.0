From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Fri, 13 Feb 2015 22:28:30 +0100
Message-ID: <20150213212830.GA29912@electric-eye.fr.zoreil.com>
References: <1423808353-8722-1-git-send-email-Yanjun.Zhu@windriver.com>
 <1423808353-8722-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com,
	viro@zeniv.linux.org.uk, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com, jonathon.reinhart@gmail.com
To: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42950 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbbBMV2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 16:28:41 -0500
Content-Disposition: inline
In-Reply-To: <1423808353-8722-2-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhu Yanjun <Yanjun.Zhu@windriver.com> :
> The default speed of normal nic is 1000M while the default speed
> of tun is 10M. Now the default speed of tun is changed to 1000M.
> And there are 3 options: 10M, 100M and 1000M to the speed of tun.
> The command "ethtool -s tun0 speed 10/100/1000" can configure the
> speed of tun dynamically.

You don't explain why this patch is needed.

Why should tun_set_settings filter speed this way/at all ?

There's no reason to pollute uapi .h file.

-- 
Ueimor
