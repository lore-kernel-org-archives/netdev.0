From: Nicola Padovano <nicola.padovano@gmail.com>
Subject: problem with flowi structure
Date: Thu, 16 Sep 2010 17:14:39 +0200
Message-ID: <AANLkTi=bGsvMqnTSanA73FhDH_DashmXTcA1sddtj0P6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:48460 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755141Ab0IPPPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 11:15:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all. I'm "studying" the flowi structure.
I see some source code:

[CODE]
...
fl.nl_u.ip4_u.saddr = 0
...
ip_route_output_key(....,&fl,....)
...
(where fl is a flowi struct)
[/CODE]

what is the meaning of saddr = 0?


-- 
Nicola Padovano
e-mail: nicola.padovano@gmail.com
web: http://npadovano.altervista.org
