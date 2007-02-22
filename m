From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET 0/18] FRTO: fixes and small changes + SACK enhanced
 version
Date: Thu, 22 Feb 2007 05:33:58 -0800 (PST)
Message-ID: <20070222.053358.92582060.davem@davemloft.net>
References: <11717439662097-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20070222.001519.66175915.davem@davemloft.net>
	<Pine.LNX.4.64.0702221305380.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44537
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751602AbXBVNd7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 08:33:59 -0500
In-Reply-To: <Pine.LNX.4.64.0702221305380.19465@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 22 Feb 2007 14:25:32 +0200 (EET)

> Before preparing the submittable spurious RTO responses patch, I woul=
d=20
> like to know what is the preferred style for the response selector co=
de=20
> (I'm controlling the response through frto_response sysctl)? switch? =
array=20
> of function pointers? If array, where to place it (considering the ne=
ed=20
> for forward declarations and mixing of code and data in some approach=
es)?

If it's just in the FRTO paths and controlled by sysctl, and the number
of cases are relatively small, just a set of if() tests or a
switch() statement would work fine.
