From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 2/6] qlge: Stand-up card should not report supporting wol.
Date: Sat, 30 Jun 2012 01:02:00 +0200
Message-ID: <20120629230200.GA22193@electric-eye.fr.zoreil.com>
References: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com> <1340994290-28832-3-git-send-email-jitendra.kalsaria@qlogic.com> <20120629213747.GB19152@electric-eye.fr.zoreil.com> <5E4F49720D0BAD499EE1F01232234BA877435B23DA@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40435 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164Ab2F2XND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 19:13:03 -0400
Content-Disposition: inline
In-Reply-To: <5E4F49720D0BAD499EE1F01232234BA877435B23DA@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(linux-zupk.site removed)

Jitendra Kalsaria <jitendra.kalsaria@qlogic.com> :
[...]
> - broken indent
> - netif_err(... "cleared successfully" ...)
> [JK] I don't think so, %s will be replace with "cleared successfully" or with "clear failed" depend upon status value.

I would not netif_err when everything is ok.

[...]
> If I read things correctly, WAKE_MAGIC can not be cleared and it makes no
> difference on the status code. It should be fixed.
> 
> [JK] You right, here we are not clearing WAKE_MAGIC but we are making sure that wol is disable when no option is set.

Imho wol should be disabled as well when neither WAKE_MAGIC nor any option
is set at all.

-- 
Ueimor
