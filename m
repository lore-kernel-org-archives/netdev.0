From: jamal <hadi@cyberus.ca>
Subject: RFC: on [ab]use of skb->cb by VLAN code
Date: Mon, 30 Jul 2007 20:59:16 -0400
Message-ID: <1185843556.5162.8.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:32654 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761675AbXGaA7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 20:59:35 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1504789wxd
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 17:59:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I was going to forget this, but its been playing in the back of my head
and wont go away....
Matt Carlson recently (while fixing the tg3 driver in my batching
patches) pointed to me that skb->cb[] was being used to pass around vlan
data. 
This seems like a bad use since there can be a lot of things between 
a real hardware driver and something that sets a vlan tag (qdiscs come
to mind).

Creating a new skb field be the reasonable thing to do here but i know
that we are trying to avoid adding new fields. Thoughts?

cheers,
jamal 

