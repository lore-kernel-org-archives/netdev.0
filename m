From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Wed, 10 Sep 2008 13:16:13 -0700 (PDT)
Message-ID: <20080910.131613.193702320.davem@davemloft.net>
References: <7e0dd21a0809100539r6fb7857cm3c74601bb8a29aa7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johnpol@2ka.mipt.ru
To: johaahn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58870
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755461AbYIJUQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 16:16:20 -0400
In-Reply-To: <7e0dd21a0809100539r6fb7857cm3c74601bb8a29aa7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Johann Baudy" <johaahn@gmail.com>
Date: Wed, 10 Sep 2008 14:39:55 +0200

> Hi All,
> 
> Sendfile() over UDP socket are currently limited to ~ 64KBytes file
> (max cork.length).
> Indeed, if you run sendfile() with a file size > 64KBytes over UDP
> socket, system call will stop and return ~64KBytes without sending
> anything on the network.
> This patch is pushing ongoing frames when frames buffer is full, to
> prevent overflow.
> 
> Signed-off-by: Johann Baudy <johann.baudy@gmail.com>

Your email client mangled the patch, turning tabs into spaces etc.
Please correct this and resubmit.
