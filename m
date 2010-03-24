From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] netlink: use the appropriate namespace pid
Date: Wed, 24 Mar 2010 10:19:37 +0200
Message-ID: <b6fcc0a1003240119h7c26d649taa1f947c2aeb6064@mail.gmail.com>
References: <20100320013850.GA13239@boeing.com>
	 <20100321.213022.22037430.davem@davemloft.net>
	 <b6fcc0a1003240058i524c95eere17c1349d14267b1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: thomas.goff@boeing.com, netdev@vger.kernel.org,
	adobriyan@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:48418 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755155Ab0CXITi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 04:19:38 -0400
Received: by pva18 with SMTP id 18so356587pva.19
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 01:19:37 -0700 (PDT)
In-Reply-To: <b6fcc0a1003240058i524c95eere17c1349d14267b1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Alexey, can you review Tom's namespace patches in this
>> set?

re netns sched patch:

* in psched_open() PDE(inode)->data isn't needed because
  it isn't used -- just pass NULL.
* drop useless trailing return; in psched_net_exit() :^)
* sch_mirred.c still won't work in netns
