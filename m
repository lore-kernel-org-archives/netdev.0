From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v7 18/24] bridge: revert br_dellink change back
 to original
Date: Sun, 10 May 2015 21:59:25 +0200
Message-ID: <20150510195925.GG2022@nanopsycho>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
 <1431276489-64199-19-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com, andrew@lunn.ch,
	simon.horman@netronome.com, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37514 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbbEJT7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 15:59:31 -0400
Received: by widdi4 with SMTP id di4so75661615wid.0
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 12:59:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431276489-64199-19-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, May 10, 2015 at 06:48:03PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>This is revert of:
>
>commit 68e331c785b8 ("bridge: offload bridge port attributes to switch asic
>if feature flag set")
>
>Restore br_dellink back to original and don't call into SELF port driver.
>rtnetlink.c:bridge_dellink() already does a call into port driver for SELF.
>
>bridge vlan add/del cmd defaults to MASTER.  From man page for bridge vlan
>add/del cmd:
>
>       self   the vlan is configured on the specified physical device.
>              Required if the device is the bridge device.
>
>       master the vlan is configured on the software bridge (default).
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
