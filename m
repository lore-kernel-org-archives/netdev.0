From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless
	radio
Date: Sun, 03 Dec 2006 20:18:02 +0100
Message-ID: <1165173482.3233.240.camel@laptopd505.fenrus.org>
References: <200612031936.34343.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@insightbb.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Lennart Poettering <lennart@poettering.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34265 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1760022AbWLCTSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 14:18:16 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200612031936.34343.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-12-03 at 19:36 +0100, Ivo van Doorn wrote:
> +
> +       down(&master->key_sem);
> + 

Hi,

this one seems to be used as a mutex only, please consider using a mutex
instead, as is the default for new code since 2.6.16 or so....

Greetings,
   Arjan van de Ven

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

