From: Oliver Neukum <oliver@neukum.org>
Subject: Re: future developments of usbnet
Date: Mon, 9 May 2011 10:42:00 +0200
Message-ID: <201105091042.01014.oliver@neukum.org>
References: <201105062045.37336.oliver@neukum.org> <BANLkTimXmHr8aJ7WgRVvZj85t-gw68C_Ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:57952 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab1EIIkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 04:40:21 -0400
In-Reply-To: <BANLkTimXmHr8aJ7WgRVvZj85t-gw68C_Ww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, 9. Mai 2011, 05:26:04 schrieb Ming Lei:

Hi,

> 2011/5/7 Oliver Neukum <oliver@neukum.org>:
> > Hi,
> >
> > I'd like to get a feeling what people are working out there regarding usbnet.
> > So please, if you do something, or think something ought to be done, please
> > speak up now.
> >
> > IMHO usbnet needs better support for
> >
> > - batching protocols
> > - double buffering on the rx path
> >
> > with the latter having higher priority.
> >
> > Coments?
> 
> Maybe another thing about rx should be considered too: we should introduce
> one flow control mechanism into rx path so that too much coming packets can
> not consume many of memory and cause out of memory for atomic allocation.

Do we really need to avoid it, or do we just need to recover?
If avoidance is needed, should we use NAPI?

	Regards
		Oliver
