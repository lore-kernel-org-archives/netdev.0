From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI: netif_rx_reschedule() ??
Date: Thu, 31 Aug 2006 17:50:55 -0400
Message-ID: <1157061055.5297.56.camel@jzny2>
References: <adau03tlvx8.fsf@cisco.com>
	 <20060830161219.7878bada@localhost.localdomain> <adapsehls1r.fsf@cisco.com>
	 <adalkp5lrod.fsf@cisco.com> <20060831142910.427f64fa@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:37042 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932456AbWHaVvL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 17:51:11 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GIuRD-0003kW-A7
	for netdev@vger.kernel.org; Thu, 31 Aug 2006 17:51:03 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060831142910.427f64fa@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-31-08 at 14:29 -0700, Stephen Hemminger wrote:
> On Wed, 30 Aug 2006 16:39:14 -0700
> Roland Dreier <rdreier@cisco.com> wrote:
> 
> >     Roland> makes sense -- especially since the caller probably also
> >     Roland> deducted N from *budget, and netif_rx_reschedule() doesn't
> >     Roland> touch that.
> > 
> > Actually, why does undoing the change to quota make sense?  Presumably
> > I passed N packets to netif_receive_skb() -- why shouldn't I deduct N
> > from quota and *budget?
> > 
> >  - R.
> 
> This was probably a preventive thing to avoid scheduling when quota remaining was zero?

I am reading backwards, so i may be incoherent ;-> 
I suppose if you dont trust the driver to tell you the truth it could be
done in the core code such as netif_receive_skb(). Should be noted
however, your quota does get refilled by the NAPI core governed by DRR
scheduling rules.

cheers,
jamal

