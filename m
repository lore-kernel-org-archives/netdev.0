From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 3/5] switchdev: add offload_fwd_mark
 generator helper
Date: Thu, 16 Jul 2015 10:22:29 +0200
Message-ID: <20150716082229.GE2145@nanopsycho.orion>
References: <1437033897-8050-1-git-send-email-sfeldma@gmail.com>
 <1437033897-8050-4-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:36503 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930AbbGPIWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 04:22:32 -0400
Received: by wgxm20 with SMTP id m20so52048808wgx.3
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 01:22:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437033897-8050-4-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 16, 2015 at 10:04:55AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>skb->offload_fwd_mark and dev->offload_fwd_mark are 32-bit and should be
>unique for device and may even be unique for a sub-set of ports within
>device, so add switchdev helper function to generate unique marks based on
>port's switch ID and group_ifindex.  group_ifindex would typically be the
>container dev's ifindex, such as the bridge's ifindex.
>
>The generator uses a global hash table to store offload_fwd_marks hashed by
>{switch ID, group_ifindex} key.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
