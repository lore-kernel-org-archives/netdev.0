From: Alexander Sverdlin <alexander.sverdlin@nsn.com>
Subject: Re: [PATCH net] Revert "net: sctp: Fix a_rwnd/rwnd management to
 reflect real state of the receiver's buffer"
Date: Tue, 15 Apr 2014 08:43:47 +0200
Message-ID: <534CD523.50301@nsn.com>
References: <1397504717-19566-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: ext Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:51220 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbaDOGn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 02:43:56 -0400
In-Reply-To: <1397504717-19566-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Daniel,

On 14/04/14 21:45, ext Daniel Borkmann wrote:
> This reverts commit ef2820a735f7 ("net: sctp: Fix a_rwnd/rwnd management
> to reflect real state of the receiver's buffer") as it introduced a
> serious performance regression on SCTP over IPv4 and IPv6, though a not
> as dramatic on the latter. Measurements are on 10Gbit/s with ixgbe NICs.

Could you please share other HW details? I wonder how much CPU power one needs for such a throughput?

-- 
Best regards,
Alexander Sverdlin.
