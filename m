From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv4] Bridge: Always send NETDEV_CHANGEADDR up on br MAC
 change.
Date: Mon, 8 Aug 2011 13:12:30 -0700
Message-ID: <20110808131230.7f4b4d99@nehalam.ftrdhcpuser.net>
References: <CALfQTu7MVjfO7vHB-mAC=RwokBRsi7vR6_XVfQX0+vU2ZCVHOw@mail.gmail.com>
	<1312578250-2944-2-git-send-email-andreiw@motorola.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrei Warkentin <andreiw@motorola.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53998 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751408Ab1HHUMV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 16:12:21 -0400
In-Reply-To: <1312578250-2944-2-git-send-email-andreiw@motorola.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Aug 2011 16:04:10 -0500
Andrei Warkentin <andreiw@motorola.com> wrote:

> This ensures the neighbor entries associated with the bridge
> dev are flushed, also invalidating the associated cached L2 headers.
> 
> This means we br_add_if/br_del_if ports to implement hand-over and
> not wind up with bridge packets going out with stale MAC.
> 
> This means we can also change MAC of port device and also not wind
> up with bridge packets going out with stale MAC.
> 
> This builds on Stephen Hemminger's patch, also handling the br_del_if
> case and the port MAC change case.
> 
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Andrei Warkentin <andreiw@motorola.com>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
