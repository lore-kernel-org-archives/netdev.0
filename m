From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 4/5] rocker: add offload_fwd_mark support
Date: Thu, 16 Jul 2015 10:22:40 +0200
Message-ID: <20150716082240.GF2145@nanopsycho.orion>
References: <1437033897-8050-1-git-send-email-sfeldma@gmail.com>
 <1437033897-8050-5-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:33543 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548AbbGPIWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 04:22:43 -0400
Received: by wgmn9 with SMTP id n9so52096971wgm.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 01:22:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437033897-8050-5-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 16, 2015 at 10:04:56AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>If device flags ingress packet as "fwd offload", mark the
>skb->offlaod_fwd_mark using the ingress port's dev->offlaod_fwd_mark.  This
>will be the hint to the kernel that this packet has already been forwarded
>by device to egress ports matching skb->offlaod_fwd_mark.
>
>For rocker, derive port dev->offlaod_fwd_mark based on device switch ID and
>port ifindex.  If port is bridged, use the bridge ifindex rather than the
>port ifindex.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
