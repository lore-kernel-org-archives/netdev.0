From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Wed, 22 Jul 2009 14:07:28 +0300
Message-ID: <200907221407.29275.remi.denis-courmont@nokia.com>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com> <20090722101102.4aba96bd@lxorguk.ukuu.org.uk> <1248254134.28545.111.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Oliver Neukum <oliver@neukum.org>,
	ext Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: ext Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:37269 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbZGVLGJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 07:06:09 -0400
In-Reply-To: <1248254134.28545.111.camel@violet>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 22 July 2009 12:15:34 ext Marcel Holtmann wrote:
> Hi Alan,
>
> > > The AT stuff is really problematic. Look at the hoops ISDN and so=
ftware
> > > modem drivers go through to emulate AT commands. I know even of a
> > > CDC-ACM modem which can't deal with AT commands inline (that's wi=
thin
> > > spec). It seems to me we should have a modem API in kernel.
> >
> > For devices which don't deal in AT commands probably but for device=
s
> > whose firmware provides an AT command interface over serial I would
> > disagree.
>
> I fully agree here. Even if you think you get AT commands under contr=
ol,
> you really won't in the end. That standard is so wildly mis-interpret=
ed
> that it is not even funny anymore.

Possibly. Does anyone known of any "species" bypassing AT commands enti=
rely,=20
other than Phonet? as far as GPRS is concerned?

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

