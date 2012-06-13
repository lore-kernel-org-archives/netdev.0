From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 4/7] usbnet: remove EVENT_DEV_OPEN flag
Date: Wed, 13 Jun 2012 09:40:54 +0200
Message-ID: <201206130940.54817.oliver@neukum.org>
References: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com> <CACVXFVPf+Q9i-Ju3GFapiTB2wEWZSBrZ2Gf=WHsLWfWfTnWGpA@mail.gmail.com> <CACVXFVOjPxK3X5RF7DVJsTj3g3MyKg_49qtaev=ZBthsjBC=OA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:38667 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727Ab2FMHoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 03:44:05 -0400
In-Reply-To: <CACVXFVOjPxK3X5RF7DVJsTj3g3MyKg_49qtaev=ZBthsjBC=OA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 13. Juni 2012, 06:47:18 schrieb Ming Lei:
> On Wed, Jun 13, 2012 at 10:12 AM, Ming Lei <tom.leiming@gmail.com> wrote:
> > On Wed, Jun 13, 2012 at 2:14 AM, Oliver Neukum <oliver@neukum.org> wrote:
> >> Am Dienstag, 12. Juni 2012, 03:19:42 schrieb Ming Lei:
> >>> EVENT_DEV_OPEN is introduced to mark if the interface is opened or
> >>> not, but we already have IFF_UP to handle it, so just
> >>> remove the flag and use IFF_UP.
> >>
> >> When is IFF_UP cleared? The flag is tested in usbnet_resume(),
> >
> > The flag is cleared just after usbnet_stop completes.
> 
> Looks we can use the below to replace EVENT_DEV_OPEN:
> 
>      (netif_running((dev)->net) && ((dev)->net->flags & IFF_UP))

That goes down a bit into the interna of the network code.
If we do this, please encapsulated and with a big fat comment.

	Regards
		Oliver
