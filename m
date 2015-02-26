From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 3/3] rocker: put port in FORWADING state after
 leaving bridge
Date: Thu, 26 Feb 2015 08:07:48 +0100
Message-ID: <20150226070748.GD2074@nanopsycho.orion>
References: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
 <1424924138-15928-4-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:35375 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbbBZHHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 02:07:52 -0500
Received: by wevl61 with SMTP id l61so8173947wev.2
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 23:07:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1424924138-15928-4-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 26, 2015 at 05:15:38AM CET, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Cleanup the port forwarding state transitions for the cases when the port
>joins or leaves a bridge, or is brought admin UP or DOWN.  When port is
>bridged, we can rely on bridge driver putting port in correct state using
>STP callback into port driver, regardless if bridge is enabled for STP or not.
>When port is not bridged, we can reuse some of the STP code to enabled or
>disable forwarding depending on UP or DOWN.
>
>Tested by trying all the transitions from bridge/not bridge, and UP/DOWN, and
>verifying port is in the correct forwarding state after each transition.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
