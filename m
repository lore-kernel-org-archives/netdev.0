From: Tim Ellis <tim.ellis@mac.com>
Subject: Re: [RFC,PATCHv2 0/6] support for DSA hardware ethernet switch
 chips
Date: Mon, 29 Sep 2008 13:53:30 +0100
Message-ID: <122189293646033115734044366977420726540-Webmail2@me.com>
References: <200509300011.j8U0Bin09458@image.techtracker.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>, Nicolas Pitre <nico@cam.org>,
	Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutw.mac.com ([17.250.248.177]:58450 "EHLO smtpoutw.mac.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968AbYI2Mx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 08:53:56 -0400
in-reply-to: <200509300011.j8U0Bin09458@image.techtracker.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
On Monday, September 29, 2008, at 03:37AM, "Lennert Buytenhek" <buytenh@wantstofly.org> wrote:

>
>- Add support for the Marvell 88E6060 ethernet switch register set,
>  and the tagging format it uses (Trailer).  Tested on a Thecus n1200
>  (http://www.thecus.com/products_over.php?cid=12&pid=24
>  http://thecus.nas-central.org/index.php/Category:N1200), where the
>  switch chip is hooked up to a Freescale mpc8347 using the gianfar
>  driver.  (I.e. it works with ethernet drivers other than mv643xx_eth.)
>  (There _is_ an issue with the gianfar hooking up to the PHY for the
>  first switch port, and refusing to send/receive data to ports 2-4 if
>  port 1 isn't up.)
>

I can confirm this works as described above on a Thecus N1200. Thanks Lennert!
