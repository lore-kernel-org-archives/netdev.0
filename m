From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 1/5] net: don't reforward packets already
 forwarded by offload device
Date: Thu, 16 Jul 2015 10:22:03 +0200
Message-ID: <20150716082203.GC2145@nanopsycho.orion>
References: <1437033897-8050-1-git-send-email-sfeldma@gmail.com>
 <1437033897-8050-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:33058 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753731AbbGPIWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 04:22:07 -0400
Received: by wgmn9 with SMTP id n9so52084739wgm.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 01:22:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437033897-8050-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 16, 2015 at 10:04:53AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Just before queuing skb for xmit on port, check if skb has been marked by
>switchdev port driver as already fordwarded by device.  If so, drop skb.  A
>non-zero skb->offload_fwd_mark field is set by the switchdev port
>driver/device on ingress to indicate the skb has already been forwarded by
>the device to egress ports with matching dev->skb_mark.  The switchdev port
>driver would assign a non-zero dev->skb_mark for each device port netdev
>during registration, for example.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
