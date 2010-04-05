From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] rps: fixed missed rps_unlock
Date: Mon, 5 Apr 2010 14:40:23 -0700
Message-ID: <t2z65634d661004051440p8b39275w99ce9101b30090d0@mail.gmail.com>
References: <alpine.DEB.1.00.1004051426140.22393@pokey.mtv.corp.google.com>
	 <1270503358.9013.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:13097 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756439Ab0DEVk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 17:40:27 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o35LePQt015453
	for <netdev@vger.kernel.org>; Mon, 5 Apr 2010 23:40:25 +0200
Received: from pwi2 (pwi2.prod.google.com [10.241.219.2])
	by kpbe17.cbf.corp.google.com with ESMTP id o35LeNUq031316
	for <netdev@vger.kernel.org>; Mon, 5 Apr 2010 14:40:24 -0700
Received: by pwi2 with SMTP id 2so3989920pwi.0
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 14:40:23 -0700 (PDT)
In-Reply-To: <1270503358.9013.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-
>
> Yes, and rps_lock()/rps_unlock() are not well chosen either, but no
> clever names come to my mind right now.
>
input_queue_lock/input_queue_unlock ?

> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>
>
>
