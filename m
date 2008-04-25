From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.26 3/5]S2io: Enabling Multi ring support
Date: Fri, 25 Apr 2008 12:03:33 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD770378875D@nekter>
References: <Pine.GSO.4.10.10804231331360.10279-100000@guinness> <481170D1.2060700@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "Jeff Garzik" <jeff@garzik.org>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:15933 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758618AbYDYQSs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 12:18:48 -0400
Content-class: urn:content-classes:message
In-Reply-To: <481170D1.2060700@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sreenivasa Honnur wrote:
> > Enable multi ring support:
> > 	- Seperate ring specific data
> > 	- Initialize all configured rings with equal priority.
> > 	- Updated boundary check for number of Rings.
> > 	- Updated per ring statistics of rx_bytes and rx_packets.
> > 	- Moved lro struct from struct s2io_nic to struct ring_info.
> >
> > Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> > Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> > Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> 
> if multi-ring support and fixes are two separate patches, then that
> creates a state whereby git-bisect might produce a broken driver.
[Ram] We created two patches so they can be reviewed easily. Do you want
us to merge the two patches and submit?

Ram
