From: David Miller <davem@davemloft.net>
Subject: Re: IPv6 neighbor advertisements
Date: Thu, 25 Mar 2010 23:07:33 -0700 (PDT)
Message-ID: <20100325.230733.214002385.davem@davemloft.net>
References: <aa711df21003252251x524d7dd2hac4a88103d0ae3a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: haile.seifu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49195
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752817Ab0CZGHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 02:07:10 -0400
In-Reply-To: <aa711df21003252251x524d7dd2hac4a88103d0ae3a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Keep in mind that net/core/neighbour.c is for IPV4 ARP too.

So if there is a conflict between what is allowed by ipv4
and what is allowed by ipv6 in this scenerio, that would
explain it.
