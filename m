From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 4 Dec 2010 16:40:07 +0100
Message-ID: <20101204154007.GA1981@del.dom.local>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
 <4CFA3F01.20109@gmail.com>
 <1291472889.2159.18.camel@mojatatu>
 <1291474127.2159.35.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40128 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755114Ab0LDPkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 10:40:18 -0500
Received: by wwa36 with SMTP id 36so11203164wwa.1
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 07:40:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1291474127.2159.35.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 04, 2010 at 09:48:47AM -0500, jamal wrote:
> On Sat, 2010-12-04 at 09:28 -0500, jamal wrote:
> 
> > The idea was to defer processing at the first error. Changli
> > is changing it to continue despite the error.
> > The initial goal was to yield whenever possible since we dont maintain
> > a lot of state.
> 
> Changli:
> Other points we could defer processing is in case of packets
> being dropped by dev_queue_xmit and netif_rx

Hmm... But we didn't care until now... ;-) Btw. is it really very
probable (and worth bothering) that this current error of NULL dev
get fixed before we purge this tq queue with deferral one by one?

Cheers,
Jarek P.
