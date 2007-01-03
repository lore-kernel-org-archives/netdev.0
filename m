From: "Evandro Clivatti Dall'Agnol" <evandrocd@gmail.com>
Subject: about tty line discipline and pppd
Date: Wed, 3 Jan 2007 11:12:20 -0200
Message-ID: <3209d0d50701030512jbb14da8y9803d7c54821ddf0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:27002 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbXACNMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 08:12:21 -0500
Received: by ug-out-1314.google.com with SMTP id 44so5165010uga
        for <netdev@vger.kernel.org>; Wed, 03 Jan 2007 05:12:20 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all, I need your advice, please.

Situation:
I have two ppc processors with their SMC2 ports connected to each
other port. Saying 'y' to SMC2 support on kernel 2.4, I can "echo foo
>> /dev/ttyS1" in one processor while "cat /dev/ttyS1" on the other
and the "foo" text appears.

Question:
I want to exchange data between these two processors through sockets
interface. The right way to do that is writing a "tty line discipline"
driver?

Another question:
I tried without sucess to setup pppd on this line, the more close to a
working pppd I got was issuing "stty -F /dev/ttyS1 -echo raw", so the
pppd appears to send the LCP packets and the other peer receive them
while I watch through "cat /dev/ttyS1" but pppd itself doesn't work.
Do you have some advice on this situation too?

Thanks in advance,
Evandro Clivatti Dall'Agnol
