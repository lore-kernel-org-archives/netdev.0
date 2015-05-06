From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 04/21] switchdev: convert parent_id_get to
 switchdev attr get
Date: Wed, 6 May 2015 05:13:11 +0200
Message-ID: <20150506031311.GB1992@nanopsycho>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
 <1430847297-15728-5-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com, andrew@lunn.ch,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:34510 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757659AbbEFDNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 23:13:24 -0400
Received: by wicmx19 with SMTP id mx19so114969633wic.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 20:13:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430847297-15728-5-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 05, 2015 at 07:34:40PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Switch ID is just a gettable port attribute.  Convert switchdev op
>switchdev_parent_id_get to a switchdev attr.
>
>Note: for sysfs and netlink interfaces, SWITCHDEV_ATTR_PORT_PARENT_ID is
>called with SWITCHDEV_F_NO_RECUSE to limit switch ID user-visiblity to only
>port netdevs.  So when a port is stacked under bond/bridge, the user can
>only query switch id via the switch ports, but not via the upper devices
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
