From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [6/8,RFC] CAIF Protocol Stack
Date: Tue, 6 Oct 2009 21:06:10 +0200
Message-ID: <61D8D34BB13CFE408D154529C120E07902ED6716@eseldmw101.eemea.ericsson.se>
References: <1253727091-10383-1-git-send-email-sjur.brandeland@stericsson.com> <4ACA0E25.5010207@babic.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	"Kim Lilliestierna XX" <kim.xx.lilliestierna@stericsson.com>
To: "Stefano Babic" <stefano.babic@babic.homelinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:50538 "EHLO
	mailgw4.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757146AbZJFTHk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 15:07:40 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4ACA0E25.5010207@babic.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefano Babic wrote:
>>  drivers/net/caif/chnl_tty.c   |  220 +++++++++++
> There is no rule in drivers/net/caif/Makefile regarding this file and
> it is not mentioned in the documentation. Is there anything missing ?
> I supposed the serial physical layer is implemented in phyif_ser.c. =20

The chnl_tty.c is a simple line-discipline providing a CAIF TTY to user=
 space, it is
obsolete and will removed from my next patch-set.
We have put our effort into stabilizing the character device (chnl_chr.=
c) instead.

BR/Sjur Br=E6ndeland

