From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v7 06/24] switchdev: convert STP update to
 switchdev attr set
Date: Sun, 10 May 2015 21:29:31 +0200
Message-ID: <20150510192931.GB2022@nanopsycho>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
 <1431276489-64199-7-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	simon.horman@netronome.com, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37866 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbbEJT3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 15:29:38 -0400
Received: by widdi4 with SMTP id di4so75258309wid.0
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 12:29:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431276489-64199-7-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, May 10, 2015 at 06:47:51PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>STP update is just a settable port attribute, so convert
>switchdev_port_stp_update to an attr set.
>
>For DSA, the prepare phase is skipped and STP updates are only done in the
>commit phase.  This is because currently the DSA drivers don't need to
>allocate any memory for STP updates and the STP update will not fail to HW
>(unless something horrible goes wrong on the MDIO bus, in which case the
>prepare phase wouldn't have been able to predict anyway).
>

Acked-by: Jiri Pirko <jiri@resnulli.us>
