From: "Steinar H. Gunderson" <sesse@samfundet.no>
Subject: Re: fe80::/64 route missing on GRE tunnels
Date: Mon, 17 Feb 2014 10:45:57 +0100
Message-ID: <20140217094557.GB32630@sesse.net>
References: <20140211215510.GA6994@sesse.net>
 <20140211215928.GA7862@sesse.net>
 <20140215074559.GA8634@order.stressinduktion.org>
 <20140215121027.GC8634@order.stressinduktion.org>
 <5301D843.4020802@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, itk-intern@samfundet.no,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:46185 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbaBQJqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 04:46:03 -0500
Content-Disposition: inline
In-Reply-To: <5301D843.4020802@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 17, 2014 at 10:37:07AM +0100, Nicolas Dichtel wrote:
> I'm not sure to understand the problem. In the case described above, there is no
> fe80::/64 route because there is no link local address.
> What source address will be used to communicate over this gre interface?

It is added (ip -6 addr add fe80::1 dev foo), but it doesn't help without the
/64 being present.

/* Steinar */
-- 
ITK-pang
http://www.sesse.net/
