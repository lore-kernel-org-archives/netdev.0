From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 1/2] d80211: Add software RTS support
Date: Mon, 5 Feb 2007 19:42:57 +0100
Message-ID: <200702051942.57753.IvDoorn@gmail.com>
References: <200701312016.50524.IvDoorn@gmail.com> <200702051907.53220.IvDoorn@gmail.com> <200702051922.46885.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Michael Buesch <mbuesch@freenet.de>,
	Johannes Berg <johannes@sipsolutions.net>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:57806 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932606AbXBESnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 13:43:19 -0500
Received: by an-out-0708.google.com with SMTP id b33so1097010ana
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 10:43:19 -0800 (PST)
In-Reply-To: <200702051922.46885.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > Did you already send that patchset to the netdev list?
> > Because I haven't seen a patch series about rts for d80211 yet.
> 
> No, linux-wireless@vger.kernel.org

Hmm, wasn't subscribed to that list yet. :(
But now I am. :)

> > The new rt2500usb and rt73usb packet ring handling no longer use a DMA buffer
> > but instead send the sk_buffer->data pointer to the USB layer.
> > The solution as suggested by Jiri could be handled by making sure the rts allocated
> > buffer will also have a tx header room as set in the tx_header_room field. But I am not
> > sure if that would be a better solution than putting the rts packet in a sk_buffer that is being
> > send out just before the real packet...
> 
> In my patchset you can put it into anything you like.
> I put it into an skb.

Sounds good, I'll look that patchset up in the mailarchive.

Ivo
