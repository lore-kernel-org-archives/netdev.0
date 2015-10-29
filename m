From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [BUG] Any-IP IPv6 support broken
Date: Thu, 29 Oct 2015 19:39:17 +0100
Message-ID: <1446143957.486796.423892137.12302CDB@webmail.messagingengine.com>
References: <0977189F-9778-4D1C-939D-FAD71595E5F6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Gilberto Bertin <gilberto.bertin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:33406 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751055AbbJ2SjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 14:39:18 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id EC03C2018C
	for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 14:39:17 -0400 (EDT)
In-Reply-To: <0977189F-9778-4D1C-939D-FAD71595E5F6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Oct 29, 2015, at 16:00, Gilberto Bertin wrote:
> 2- note that it's not actually working with IPv6 addresses:
> 
> # ip -6 route add local abcd:abcd:abcd:abcd::/64 dev eth0


Try the loopback interface:

ip -6 route add local abcd:abcd:abcd:abcd::/64 dev *lo*

Otherwise packets should end up in neighbor subsystem and you don't want
that, still. ;)

Bye,
Hannes
