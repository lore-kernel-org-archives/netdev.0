From: David Miller <davem@davemloft.net>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Wed, 03 Sep 2008 04:06:26 -0700 (PDT)
Message-ID: <20080903.040626.198546183.davem@davemloft.net>
References: <20080902194603.GA2825@2ka.mipt.ru>
	<7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com>
	<7e0dd21a0809030338k3335a5eah4be6e27c26aecf59@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: johaahn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47765
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751181AbYICLGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 07:06:33 -0400
In-Reply-To: <7e0dd21a0809030338k3335a5eah4be6e27c26aecf59@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Johann Baudy" <johaahn@gmail.com>
Date: Wed, 3 Sep 2008 12:38:53 +0200

> I'm not able to exceed 15Mo/s even with vmsplice/splice duo.

I think you misunderstood what Evgeniy was asking of you.

He was asking how fast you can transfer data over this
interface using a normal TCP socket to a remove host,
via sendfile() or splice().
