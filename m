From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] net : enable tx time stamping in the vde driver.
Date: Thu, 06 Dec 2012 20:25:27 +0100
Message-ID: <c4e79fec-779a-4ddf-8330-87e54486b4f8@email.android.com>
References: <1354807505-21222-1-git-send-email-paul.chavent@onera.fr> <20121206185742.GA2175@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: jdike@addtoit.com, user-mode-linux-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>,
	Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:47834 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755370Ab2LFTZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2012 14:25:10 -0500
In-Reply-To: <20121206185742.GA2175@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Richard Cochran <richardcochran@gmail.com> schrieb:

>On Thu, Dec 06, 2012 at 04:25:05PM +0100, Paul Chavent wrote:
>> This new version moves the skb_tx_timestamp in the main uml
>> driver. This should avoid the need to call this function in each
>> transport (vde, slirp, tuntap, ...). It also add support for ethtool
>> get_ts_info.
>> 
>> Signed-off-by: Paul Chavent <paul.chavent@onera.fr>
>
>Acked-by: Richard Cochran <richardcochran@gmail.com>

Queued for 3.8.

Thanks,
//richard
