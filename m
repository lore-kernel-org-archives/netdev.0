From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP splice
Date: Mon, 24 Jun 2013 10:53:38 -0700
Message-ID: <1372096418.3301.75.camel@edumazet-glaptop>
References: <CACYKsS7pMFNdBxU2raMphKyb1zU7MEbhc=vsD+FdZ5sgFq71NQ@mail.gmail.com>
	 <1372088554.1896.3.camel@bwh-desktop.uk.level5networks.com>
	 <20130624155154.GD10413@order.stressinduktion.org>
	 <1372089776.1896.9.camel@bwh-desktop.uk.level5networks.com>
	 <20130624170119.GE10413@order.stressinduktion.org>
	 <CACYKsS5uy6nGbtCYit0eNyBSemzimgLrVdUJAgeBmZwDAy7F-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Ricardo Landim <ricardolan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:33964 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817Ab3FXRxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 13:53:33 -0400
Received: by mail-ee0-f49.google.com with SMTP id b57so6075641eek.8
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 10:53:32 -0700 (PDT)
In-Reply-To: <CACYKsS5uy6nGbtCYit0eNyBSemzimgLrVdUJAgeBmZwDAy7F-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-24 at 14:09 -0300, Ricardo Landim wrote:
> Useful for UDP proxy, mainly for RTP payload including voice (voip)
> and video live stream...


I really doubt splice could help voip streams, they usually send one
small frame every 20 ms. Implementing splice() for such small frame
would be not really useful.

For video, I would rather use a kernel helper (netfilter/conntrack ?) to
avoid userland switch...
