From: jamal <hadi@cyberus.ca>
Subject: [RFC]: xfrm by mark
Date: Sun, 07 Feb 2010 13:32:02 -0500
Message-ID: <1265567522.3688.27.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f191.google.com ([209.85.221.191]:52357 "EHLO
	mail-qy0-f191.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378Ab0BGSjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2010 13:39:04 -0500
Received: by qyk29 with SMTP id 29so2774783qyk.23
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2010 10:39:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While catching up with old netdev threads I noticed this one:
http://marc.info/?l=linux-netdev&m=125621829709171&w=2
I had a chat with Timo and he is too busy on other things at
the moment. I have some cycles to burn and would like to pursue
this unless there is objection to the general idea. I am interested
because I would like to see most of the net stack capable of 
reference by mark. I am posting this so i can get a general
pulse before i go off coding.

Approach:
- introduce attribute XFRMA_MARK
- both SPD and SAD will have new entries ->mark
- by default mark is 0, so backward compat for 
control add/get/del as well as fast path lookup continues.
I dont plan to touch pfkey i.e anything injected by pfkey
will use default mark of 0.
- a sysctl to turn off this feature doesnt seem necessary
since the cycles added by the fast path lookup dont seem
to be much more..

Timo, please chime in with anything i may have missed.


cheers,
jamal

