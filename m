From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Interface working only after first packet is sent out ...
Date: Thu, 13 Sep 2012 11:48:06 +0200
Message-ID: <CAF6-1L4H7AtT0OP4C0E1wHdrRs+T0r9Qv17wDntZsnJbYv9xaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:44432 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755895Ab2IMJsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 05:48:07 -0400
Received: by vbbff1 with SMTP id ff1so3173953vbb.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 02:48:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


I've been having an issue for a fairly long time, on several system
(either physical or virtual machine).

Basically I don't have network connectivity until the machine
initiates it's first packet out.

So let's say I just booted the machine (and it has no sw running on
it, just base system), if I try to ping it, it won't respond.
In a tcpdump on the interface, I can see the incoming ping, but not
outgoing responses.

Now from the machine itself, I generate a single ping to anywhere,
then everything will start working as expected and it will last
forever until the next reboot.

Has anyone ever seen something like this ?

Most of the time I don't notice it because either it's a desktop
machine and then even just a DHCP request makes it work from boot, or
even on server, the ntp daemon generates the first packet and it
works.

I don't know if it's a bug or if I'm doing something wrong somewhere,
but I really don't see what it could be ....



Cheers,

    Sylvain
