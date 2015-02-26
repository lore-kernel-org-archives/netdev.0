From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/3] rocker: fix non-portable err return codes
Date: Thu, 26 Feb 2015 07:50:48 +0100
Message-ID: <20150226065048.GB2074@nanopsycho.orion>
References: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
 <1424924138-15928-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:47086 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884AbbBZGuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 01:50:51 -0500
Received: by wevm14 with SMTP id m14so8013808wev.13
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 22:50:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1424924138-15928-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 26, 2015 at 05:15:36AM CET, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>The rocker device returns error codes if something goes wrong with descriptor
>processing.  Originally the device used standard errno codes for different
>errors, but since those errno codes aren't portable across ARCHs, the device
>now returns hard-coded error codes that stay constant across diff ARCHs.  Fix
>driver to use those same hard-coded values.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
