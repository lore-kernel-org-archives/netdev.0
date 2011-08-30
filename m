From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH 5/7] bnx2x: do not set TPA flags and features in bnx2x_init_bp
Date: Tue, 30 Aug 2011 19:15:21 +0200
Message-ID: <4E5D1AA9.2010702@redhat.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com> <1314714646-3642-6-git-send-email-mschmidt@redhat.com> <201108301921.22838.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Vlad Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32688 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754698Ab1H3RPY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 13:15:24 -0400
In-Reply-To: <201108301921.22838.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2011 06:21 PM, Vlad Zolotarov wrote:
> NACK
>
> This patch will cause the bnx2x to initialize HW with LRO disabled on the
> first ifup because our code considers the TPA_ENABLE_FLAG when desiding on
> whether LRO is enabled or not. ethtool would still report the LRO on though!

I see. I thought register_netdevice() would always call 
bnx2x_set_features(), but this is not the case.

Patch 7/7 has a similar problem with RX_VLAN_STRIP_FLAG then.

Michal
