From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 16/21] switchdev: add new
 switchdev_port_bridge_getlink
Date: Thu, 7 May 2015 17:48:35 +0200
Message-ID: <20150507154834.GC2121@nanopsycho>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
 <1430847297-15728-17-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com, andrew@lunn.ch,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33639 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbbEGPsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 11:48:38 -0400
Received: by wief7 with SMTP id f7so17074179wie.0
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 08:48:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430847297-15728-17-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 05, 2015 at 07:34:52PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Like bridge_setlink, add switchdev wrapper to handle bridge_getlink and
>call into port driver to get port attrs.  For now, only BR_LEARNING and
>BR_LEARNING_SYNC are returned.  To add more, we'll probably want to break
>away from ndo_dflt_bridge_getlink() and build the netlink skb directly in
>the switchdev code.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
