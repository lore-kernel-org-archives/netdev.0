From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: How to use ixp4xx_hss (or generic-hdlc?)
Date: Thu, 20 Nov 2008 18:42:52 +0100
Message-ID: <b0438a630811200942nac803a4hb0c054bf28195cb3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:17091 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784AbYKTRmy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 12:42:54 -0500
Received: by yx-out-2324.google.com with SMTP id 8so257621yxm.1
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2008 09:42:53 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Is there any kind of tutorials on using generic-hdlc interfaces? I
just want to make a simple point-to-point connection between two
devices using ixp4xx_hss. I would like the data to be packetized using
hdlc.

So... The questions are...
-  I suppose I should use sethdlc to configure the interface, but I am
not sure about the configuration except that I should set "hdlc"
protocol (I hope).
- Then I should "open" the interface. I am trying with "ifconfig hdlc0
up", but I obtain an "ifconfig: SIOCSIFFLAGS: Function not
implemented". As my previous use of net devices has been using
ethernet or wifi devices in an "IP world", I am not quite sure if
ifconfig should be used in this case.
- Then I hope that I should open a raw (SOCK_RAW) PF_PACKET socket
with protocol IPPROTO_RAW? I am not using IP, so this does not seem to
be the correct protocol, but...
- And the address to sendto the data? Should it be formed just using
the name of the interface or it requires more data?

Thanks. I know these should be really newbie questions, but I am
finding difficult to know how to manage a "serial" device using a
netdev interface.

Miguel =C1ngel =C1lvarez
