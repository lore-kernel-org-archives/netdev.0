From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH net,stable] cdc_ncm: workaround for EM7455 "silent" data
 interface
Date: Mon, 04 Jul 2016 10:06:45 +0200
Message-ID: <1467619605.9978.4.camel@suse.com>
References: <1467577490-27810-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38753 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932232AbcGDIKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 04:10:54 -0400
In-Reply-To: <1467577490-27810-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-07-03 at 22:24 +0200, Bj=C3=B8rn Mork wrote:
> Several Lenovo users have reported problems with their Sierra
> Wireless EM7455 modem. The driver has loaded successfully and
> the MBIM management channel has appeared to work, including
> establishing a connection to the mobile network. But no frames
> have been received over the data interface.

If this is needed in open() it must also be needed in reset_resume()

	Regards
		Oliver
