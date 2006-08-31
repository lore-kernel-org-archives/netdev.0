From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: NAPI: netif_rx_reschedule() ??
Date: Thu, 31 Aug 2006 14:29:10 -0700
Message-ID: <20060831142910.427f64fa@localhost.localdomain>
References: <adau03tlvx8.fsf@cisco.com>
	<20060830161219.7878bada@localhost.localdomain>
	<adapsehls1r.fsf@cisco.com>
	<adalkp5lrod.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39384 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751182AbWHaV3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 17:29:14 -0400
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adalkp5lrod.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2006 16:39:14 -0700
Roland Dreier <rdreier@cisco.com> wrote:

>     Roland> makes sense -- especially since the caller probably also
>     Roland> deducted N from *budget, and netif_rx_reschedule() doesn't
>     Roland> touch that.
> 
> Actually, why does undoing the change to quota make sense?  Presumably
> I passed N packets to netif_receive_skb() -- why shouldn't I deduct N
> from quota and *budget?
> 
>  - R.

This was probably a preventive thing to avoid scheduling when quota remaining was zero?


-- 
Stephen Hemminger <shemminger@osdl.org>
