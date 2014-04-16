From: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Subject: Re: [PATCH net] Revert "net: sctp: Fix a_rwnd/rwnd management to
 reflect real state of the receiver's buffer"
Date: Wed, 16 Apr 2014 08:57:24 +0200
Message-ID: <534E29D4.60100@nsn.com>
References: <1397504717-19566-1-git-send-email-dborkman@redhat.com> <534C3DC2.9070604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Alexander Sverdlin <alexander.sverdlin@nsn.com>
To: ext Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:46100 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbaDPG7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 02:59:13 -0400
In-Reply-To: <534C3DC2.9070604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Vlad,

On 04/14/2014 09:57 PM, ext Vlad Yasevich wrote:
> The base approach is sound.  The idea is to calculate rwnd based
> on receiver buffer available.  The algorithm chosen however, is
> gives a much higher preference to small data and penalizes large
> data transfers.  We need to figure our something else here..

I don't follow you here. Could you please explain what do you see as penalty?

Thanks,

Matija
