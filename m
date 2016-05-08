From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] net: l3mdev: Add hook in ip and ipv6
Date: Sun, 8 May 2016 08:44:40 +0300
Message-ID: <20160508084440.49a6865a@halley>
References: <1462585781-9146-1-git-send-email-dsa@cumulusnetworks.com>
	<1462585781-9146-2-git-send-email-dsa@cumulusnetworks.com>
	<20160507113025.67c3ab43@halley>
	<572E00C9.4050109@cumulusnetworks.com>
	<20160507213205.02529bde@halley>
	<572EA3A4.9010200@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38123 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbcEHFos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 01:44:48 -0400
Received: by mail-wm0-f43.google.com with SMTP id g17so135636835wme.1
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 22:44:48 -0700 (PDT)
In-Reply-To: <572EA3A4.9010200@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, 7 May 2016 20:25:40 -0600 David Ahern <dsa@cumulusnetworks.com> wrote:
> >   - On which circumstances we end up entering
> >     l3mdev_ip_rcv/l3mdev_ip6_rcv where skb->dev is the master?
> >     If I got it right, we enter 'ip_rcv_finish' on a slave device,
> >     the callback is invoked and eventually sets skb->dev and skb->skb_iif
> >     to the VRF device; then ip_rcv_finish continues processing the
> >     altered skb (with the changed skb->dev).
> >     So on which cicumstances do we enter 'ip_rcv_finish' where the
> >     skb->dev is ALREADY a master device?  
> 
> If you look at the full patchset I posted on 5/4 the patch after PKTINFO 
> allows local traffic. That change needs the netif_is_l3_master().

I see. Thanks David.
