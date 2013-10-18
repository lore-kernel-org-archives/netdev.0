From: Valentijn Sessink <valentyn@blub.net>
Subject: Re: IPv6 path discovery oddities - flushing the routing cache resolves
Date: Fri, 18 Oct 2013 08:44:46 +0200
Message-ID: <5260D8DE.30303@blub.net>
References: <525E6B03.1040409@blub.net> <20131016154841.GC18135@order.stressinduktion.org> <525FC1C4.3070605@blub.net> <20131018030440.GI18135@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([178.63.187.165]:57713 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021Ab3JRGwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 02:52:34 -0400
Received: from localhost (localhost [127.0.0.1])
	by filter.openoffice.nl (Postfix) with ESMTP id 2CD7B6EBF1
	for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:44:48 +0200 (CEST)
Received: from filter.openoffice.nl ([127.0.0.1])
	by localhost (filter.openoffice.nl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0hoI76D5tzrh for <netdev@vger.kernel.org>;
	Fri, 18 Oct 2013 08:44:46 +0200 (CEST)
Received: from blub.net (unknown [IPv6:2001:7b8:1529:0:5054:ff:fe70:c2c4])
	by filter.openoffice.nl (Postfix) with ESMTP id 608096EB18
	for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:44:46 +0200 (CEST)
Received: from [IPv6:2001:1af8:ff03:3:219:66ff:fe26:6dd] (unknown [IPv6:2001:1af8:ff03:3:219:66ff:fe26:6dd])
	by blub.net (Postfix) with ESMTPSA id 12F263002E5
	for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:44:46 +0200 (CEST)
In-Reply-To: <20131018030440.GI18135@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18-10-13 05:04, Hannes Frederic Sowa wrote:
> Thanks, I needed this to verify I am on the right track replicating this.
> 2001:1af8:ff03:3:219:66ff:fe26:6dd is the other end of the connection, I
> guess?

Yes, the working connection (first example) is from
2001:1af8:ff03:3:219:66ff:fe26:6dd. The non-working connection should
have an MTU of 1280 on the 2001:7b8:1529:: subnet connections (those are
tunneled, with the tunnel restricting the MTU).

Best regards,

Valentijn
