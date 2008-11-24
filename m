From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: respin of hso patches for linux-2.6.28-rc6 hso_close_fix.patch
 [patch 2/6 ]
Date: Mon, 24 Nov 2008 16:50:19 +0000
Message-ID: <20081124165019.624ee996@lxorguk.ukuu.org.uk>
References: <492ABD5A.4000006@option.com>
	<FBF372EF-F4F8-479B-B2E7-0E93D96B252B@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Denis Joseph Barrow <D.Barow@option.com>,
	Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:57959 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753354AbYKXQuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 11:50:12 -0500
In-Reply-To: <FBF372EF-F4F8-479B-B2E7-0E93D96B252B@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > 	D1("Closing serial port");
> > +	if (serial == NULL || serial->magic != HSO_SERIAL_MAGIC) {
> > +		D1("invalid serial structure bailing out.\n");
> > +		return;
> > +	}
> 
> using !serial instead of serial == NULL would be better.

A lot of serial code uses == NULL and its just as clear IMHO.

A bigger concern would be the lack of refcounting. Really for 2.6.28 now
the refcount patches are in the direction should be refcounting the tty
objects at least.

I've got a pair of proposed patches I'll post for comment

Alan
