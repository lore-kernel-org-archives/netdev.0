From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sun, 04 Jun 2006 22:51:08 +0100
Message-ID: <448355CC.3030401@gentoo.org>
References: <44817083.508@gentoo.org> <200606040025.32275.oliver@neukum.org>	 <ada605fb0606040929p7a6ea69aw9488a75d611b23e5@mail.gmail.com>	 <200606041917.55496.oliver@neukum.org> <ae5426fb0606041103od6bf095sd4403ab2966a1e1f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>, John Que <qwejohn@gmail.com>,
	linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:26806 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932277AbWFDVuj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 17:50:39 -0400
To: Rami Rosen <rosenrami@gmail.com>
In-Reply-To: <ae5426fb0606041103od6bf095sd4403ab2966a1e1f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rami Rosen wrote:
> It is mentioned there that these definitions are taken from the ZYDAS
> driver and  not all of them are relevant for the rewrite driver;
> however, it seems to me that
> removing them may be thought of.

They are mostly relevant, not all come from the vendor driver directly, 
some will be used later, many are useful for documenting the bits and 
bobs that we *do* know about the CR registers (not a lot).

I don't think there are any readability issues while all defines are 
kept out of the way from the code.

Daniel
