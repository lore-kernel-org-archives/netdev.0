From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 18/21] switchdev: convert fib_ipv4_add/del
 over to switchdev_port_obj_add/del
Date: Thu, 7 May 2015 18:10:10 +0200
Message-ID: <20150507161010.GE2121@nanopsycho>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
 <1430847297-15728-19-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com, andrew@lunn.ch,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:33444 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbbEGQKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 12:10:14 -0400
Received: by wgin8 with SMTP id n8so48516910wgi.0
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 09:10:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430847297-15728-19-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 05, 2015 at 07:34:54PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>The IPv4 FIB ops convert nicely to the switchdev objs and we're left with
>only four switchdev ops: port get/set and port add/del.  Other objs will
>follow, such as FDB.  So go ahead and convert IPv4 FIB over to switchdev
>obj for consistency, anticipating more objs to come.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
