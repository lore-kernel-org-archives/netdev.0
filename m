From: David Miller <davem@davemloft.net>
Subject: Re: query: bnx2 and tg3 don't check tcp and/or ip header length
 validity?
Date: Wed, 14 Oct 2009 17:49:08 -0700 (PDT)
Message-ID: <20091014.174908.148829136.davem@davemloft.net>
References: <4AD638AC.3000901@gmail.com>
	<1255555458.20869.221.camel@nseg_linux_HP1.broadcom.com>
	<4AD66F84.2010703@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55240
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752442AbZJOAtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 20:49:12 -0400
In-Reply-To: <4AD66F84.2010703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is transmit, and the packets can only come from the Linux
TCP stack, not some external entity.

You're being way too anal here, and adding these checks to
drivers would be just a lot of rediculious bloat.
