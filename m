From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 2/2] ping: use ipv6_iface_scope_id() to get
 scope id
Date: Mon, 03 Jun 2013 16:16:18 +0800
Message-ID: <1370247378.32297.14.camel@cr0>
References: <1370238959-32008-1-git-send-email-amwang@redhat.com>
	 <1370238959-32008-2-git-send-email-amwang@redhat.com>
	 <CAKD1Yr1gSjGq-G-G_YLgpUNTy5P8H-OD+rnqLCyW18mVB_bGDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999Ab3FCIQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 04:16:25 -0400
In-Reply-To: <CAKD1Yr1gSjGq-G-G_YLgpUNTy5P8H-OD+rnqLCyW18mVB_bGDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 16:59 +0900, Lorenzo Colitti wrote:
> 
> Good catch, thanks. While you're at it - if np->sndflow is false,
> sin6_flowinfo is not being initialized either. Care to fix that too?
> The other functions do this like this:
> 
> sin->sin6_flowinfo = 0;
> if (np->sndflow)
>         sin6->sin6_flowinfo = ip6_flowinfo(ip6);

OK, I will add this piece and resend patch 2/2.
