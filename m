From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH bluetooth-next v2] ieee802154: fix netns settings
Date: Wed, 28 Jan 2015 21:36:54 +0100
Message-ID: <20150128203645.GB30188@omega>
References: <alex.aring@gmail.com>
 <1422457112-4377-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-wpan@vger.kernel.org, marcel@holtmann.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:55250 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754346AbbA1Ug6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:36:58 -0500
Content-Disposition: inline
In-Reply-To: <1422457112-4377-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 28, 2015 at 03:58:32PM +0100, Nicolas Dichtel wrote:
> 6LoWPAN currently doesn't supports x-netns and works only in init_net.
> 
> With this patch, we ensure that:
>  - the wpan interface cannot be moved to another netns;
>  - the 6lowpan interface cannot be moved to another netns;
>  - the wpan interface is in the same netns than the 6lowpan interface;
>  - the 6lowpan interface is in init_net.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Alexander Aring <alex.aring@gmail.com>

Marcel, can you please queue this for bluetooth-next?

Thanks.

- Alex
