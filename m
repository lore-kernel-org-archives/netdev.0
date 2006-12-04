From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless
	radio
Date: Mon, 04 Dec 2006 09:53:43 +0100
Message-ID: <1165222423.12640.15.camel@localhost>
References: <200612031936.34343.IvDoorn@gmail.com>
	 <1165175065.3178.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ivo van Doorn <ivdoorn@gmail.com>,
	Dmitry Torokhov <dtor@insightbb.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Lennart Poettering <lennart@poettering.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>, davidz@redhat.com,
	Bastien Nocera <bnocera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:51911 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S1759735AbWLDIyS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 03:54:18 -0500
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1165175065.3178.10.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dan,

> 3) How does this interact with HAL?  What's the userspace interface that
> HAL will listen to to receive the signals?  NetworkManager will need to
> listen to HAL for these, as rfkill switches are one big thing that NM
> does not handle now due to lack of a standard mechanism.
> 
> In any case, any movement on rfkill interface/handling standardization
> is quite welcome :)

I want some handling for the Bluetooth rfkill in HAL, so our config
application can physically turn on/off the Bluetooth chip with a simple
method call to the HAL D-Bus interface. We also need to discover the
existence of such a rfkill switch.

Regards

Marcel


