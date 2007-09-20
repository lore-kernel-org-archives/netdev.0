From: jamal <hadi@cyberus.ca>
Subject: Re: [LARTC] ifb and ppp
Date: Thu, 20 Sep 2007 09:19:48 -0400
Message-ID: <1190294388.4734.6.camel@localhost>
References: <200709191417.43768.mail@frithjof-hammer.de>
	 <46F11E76.8030202@trash.net> <200709192342.03646.mail@frithjof-hammer.de>
	 <46F25F9A.7010007@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Frithjof Hammer <mail@frithjof-hammer.de>, lartc@mailman.ds9a.nl,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.229]:59351 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753907AbXITNTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 09:19:54 -0400
Received: by wr-out-0506.google.com with SMTP id 36so198443wra
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 06:19:53 -0700 (PDT)
In-Reply-To: <46F25F9A.7010007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-20-09 at 13:55 +0200, Patrick McHardy wrote:
> Please keep netdev and myself CCed.

and me too (I am way behind on netdev)

> Frithjof Hammer wrote:

> > Any further help/ideas?

Sorry, I didnt follow the thread - what is the goal to be achieved with
the setup?

> I misread the code, the device it looks at in tcf_mirred_init is
> the target device (ifb). So what it does is check whether the
> target device wants a link layer header and if it does restores
> the one from the source device. So currently it seems impossible
> to get rid of the PPP(oE) header.

It is tricky to redirect from devices that have disparity
in their view of link layer headers except for those that we know
dont expect anything. 

> Jamal, is that how its supposed to work?

Right - some netdevices on receipt will expect the link layer header.

cheers,
jamal

