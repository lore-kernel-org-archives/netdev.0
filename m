From: Madhan <madhan.mepco@gmail.com>
Subject: REDIRECT and UDP in client
Date: Tue, 11 Aug 2015 23:30:27 +0530
Message-ID: <CA+BD1JGexkpAcJjt73FGRYu+8UUbGeqW-FoFm0dgmyBmgKuViQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:34554 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753698AbbHKSAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 14:00:48 -0400
Received: by wicne3 with SMTP id ne3so187423901wic.1
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 11:00:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All ,
I am trying to redirect the udp packet to particular port where I run
my proxy (SOCKS) . I am supposed to obtain the original destination
ipaddress of the client to add to the data field of socks message as
per the RFC .

However , when I use REDIRECT chain as it sets the dest addr to the LO
address i get the LO address 127.0.0.1 and the port where socks proxy
client runs .

I tried patching SO_ORIGINAL_DST to obtain for UDP protocol also . In
this case it would work if I use single FD for single dest . However
when I use single FD for multiple connection it might not work .


I cannot add as part of rsvmsg , as I have to send to the proxy server
in advance .

TPROXY works in prerouting , I am not sure how we use in the client
side to send the first packet with the dest address . (I am not sure
about the TPROXYing though)


Can you please suggest the method to overcome the problem . Thanks in advance.

Regards,
Madhan Raj K ,
Senior Software Engineer - Android R&D ,
Samsung Research Institute - Bangalore .
