From: Roland Dreier <rdreier@cisco.com>
Subject: Re: NAPI: netif_rx_reschedule() ??
Date: Wed, 30 Aug 2006 16:39:14 -0700
Message-ID: <adalkp5lrod.fsf@cisco.com>
References: <adau03tlvx8.fsf@cisco.com>
	<20060830161219.7878bada@localhost.localdomain>
	<adapsehls1r.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:60167 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S932246AbWH3XjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 19:39:16 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <adapsehls1r.fsf@cisco.com> (Roland Dreier's message of "Wed, 30 Aug 2006 16:31:12 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Roland> makes sense -- especially since the caller probably also
    Roland> deducted N from *budget, and netif_rx_reschedule() doesn't
    Roland> touch that.

Actually, why does undoing the change to quota make sense?  Presumably
I passed N packets to netif_receive_skb() -- why shouldn't I deduct N
from quota and *budget?

 - R.
