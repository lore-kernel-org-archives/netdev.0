From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Fri, 24 Jul 2009 14:01:19 +0200
Message-ID: <200907241401.20262.oliver@neukum.org>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com> <20090722101102.4aba96bd@lxorguk.ukuu.org.uk> <1248254134.28545.111.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	" =?iso-8859-15?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>,
	ext Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:58226 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbZGXMA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 08:00:57 -0400
In-Reply-To: <1248254134.28545.111.camel@violet>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 22. Juli 2009 11:15:34 schrieb Marcel Holtmann:
> > > The AT stuff is really problematic. Look at the hoops ISDN and software
> > > modem drivers go through to emulate AT commands. I know even of a
> > > CDC-ACM modem which can't deal with AT commands inline (that's within
> > > spec). It seems to me we should have a modem API in kernel.
> >
> > For devices which don't deal in AT commands probably but for devices
> > whose firmware provides an AT command interface over serial I would
> > disagree.
>
> I fully agree here. Even if you think you get AT commands under control,
> you really won't in the end. That standard is so wildly mis-interpreted
> that it is not even funny anymore.

For these devices we could at least separate the data channel from the
control channel.

	Regards
		Oliver

