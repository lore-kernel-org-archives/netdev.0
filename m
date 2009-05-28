From: Piotrek D <regis44@gmail.com>
Subject: HTB class parameter change
Date: Thu, 28 May 2009 22:47:39 +0200
Message-ID: <620d582f0905281347w5aa96a85na5339aed87db5464@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:35546 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757717AbZE1Uri convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 16:47:38 -0400
Received: by fxm12 with SMTP id 12so3979551fxm.37
        for <netdev@vger.kernel.org>; Thu, 28 May 2009 13:47:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI,

I am trying to change the rate parameter of HTB class by using this
code from within one of my functions :

=A0struct htb_class *cl;
=A0cl=3Dhtb_find(number,q);

=A0cl->rate->rate.rate =3D NEW_RATE_VALUE;

=A0TC shows the correct values, but the traffic rate doesn't change a b=
it.
=A0Does anyboyd have any idea what am I doing wrong ? Maybe there would
be a faster way by sending a netlink =A0message ?

Piotrek
