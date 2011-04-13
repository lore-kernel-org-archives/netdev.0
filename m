From: RichardFliam <RichardFliam@gmail.com>
Subject: Best route for re-implementing TCPHA
Date: Wed, 13 Apr 2011 17:08:33 -0600
Message-ID: <BANLkTimLBN6z1OTLGiuADNCxAUiOsbvsGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:46761 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758603Ab1DMXIe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 19:08:34 -0400
Received: by vws1 with SMTP id 1so874383vws.19
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 16:08:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCPHA (http://dragon.linux-vs.org/~dragonfly/htm/tcpha.htm)=A0provided
several neat features for content and health aware load balancing. I
am looking to re-implement on the 2.6 kernel and I am struck by
indecision on a few key features.

In particular the original project created its own polling methods for
TCP sockets based on fs/select.c and tcp_poll but to me this seems
inelegant. I am wondering if there is a "correct" way to poll sockets
in kernel or should I simply call sock_map_fd on the kernel socket.

After extensive searching I did find this post
http://permalink.gmane.org/gmane.linux.network/180354 to this mailing
list, but it does not seem to contain an answer as to the correct
direction for polling tcp sockets in kernel.

--
--Richard Fliam
