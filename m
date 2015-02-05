From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH bluetooth-next v2] ieee802154: fix netns settings
Date: Thu, 5 Feb 2015 10:10:17 +0100
Message-ID: <20150205091016.GC12279@omega>
References: <alex.aring@gmail.com>
 <1422457112-4377-1-git-send-email-nicolas.dichtel@6wind.com>
 <20150128203645.GB30188@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-wpan@vger.kernel.org, marcel@holtmann.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:47089 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911AbbBEJKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 04:10:22 -0500
Content-Disposition: inline
In-Reply-To: <20150128203645.GB30188@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2015 at 09:36:53PM +0100, Alexander Aring wrote:
> On Wed, Jan 28, 2015 at 03:58:32PM +0100, Nicolas Dichtel wrote:
> > 6LoWPAN currently doesn't supports x-netns and works only in init_net.
> > 
> > With this patch, we ensure that:
> >  - the wpan interface cannot be moved to another netns;
> >  - the 6lowpan interface cannot be moved to another netns;
> >  - the wpan interface is in the same netns than the 6lowpan interface;
> >  - the 6lowpan interface is in init_net.
> > 
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Acked-by: Alexander Aring <alex.aring@gmail.com>
> 
> Marcel, can you please queue this for bluetooth-next?
> 

ping.

- Alex
