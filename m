From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 04 Dec 2010 09:48:47 -0500
Message-ID: <1291474127.2159.35.camel@mojatatu>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
	 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
	 <4CFA3F01.20109@gmail.com>  <1291472889.2159.18.camel@mojatatu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:36847 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314Ab0LDOsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 09:48:52 -0500
Received: by gxk19 with SMTP id 19so5663787gxk.11
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 06:48:52 -0800 (PST)
In-Reply-To: <1291472889.2159.18.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-12-04 at 09:28 -0500, jamal wrote:

> The idea was to defer processing at the first error. Changli
> is changing it to continue despite the error.
> The initial goal was to yield whenever possible since we dont maintain
> a lot of state.

Changli:
Other points we could defer processing is in case of packets
being dropped by dev_queue_xmit and netif_rx

cheers,
jamal

