From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH] net: suspicious test in dev_change_name()
Date: Mon, 02 Nov 2009 00:05:49 -0800 (PST)
Message-ID: <20091102.000549.114598716.davem@davemloft.net>
References: <4AEAAFC4.9050309@gmail.com>
	<4AEB7BB1.9000901@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46839
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753885AbZKBIFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 03:05:24 -0500
In-Reply-To: <4AEB7BB1.9000901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 31 Oct 2009 00:50:09 +0100

> I don't think so: err stores the previous ret meaning rollback and
> is checked for this later. But somebody forgot err can store previous
> (positive) value here, so IMHO you're right: there is a bug in this
> place ;-)

Just not the one Eric is specifically fixing :-)
