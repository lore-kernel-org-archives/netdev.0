From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 17:00:35 +0300
Message-ID: <200808271700.36029.denys@visp.net.lb>
References: <200808220457.40892.denys@visp.net.lb> <200808271509.18529.denys@visp.net.lb> <20080827123635.GA25321@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:51077 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759371AbYH0OCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 10:02:07 -0400
In-Reply-To: <20080827123635.GA25321@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 27 August 2008, Evgeniy Polyakov wrote:
> Can you put debug print into
> net_enable_timestamp()/net_disable_timestamp() to determine if someone
> enabled timestamp socket option?
OK, i will do that on next system reboot.

> > 0.0.0.0:*                          3207/udhcpd
>
> This one looks suspicious                                                  
>      ^^^^^^^^^^
It is busybox udhcpd... i guess it is innocent. Even i kill it - it doesn't 
change anything at all. 
Only who possible listen multicast socket - it is ripd, i cannot kill him. But 
i think it doesn't matter much too...

