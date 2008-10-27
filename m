From: Jan Evert van Grootheest <j.e.van.grootheest@caiway.nl>
Subject: broken rtl8139 and dropped frames decreasing?
Date: Mon, 27 Oct 2008 09:13:08 +0100
Message-ID: <49057814.2000403@caiway.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pelian2.kabelfoon.nl ([62.45.45.41]:55158 "EHLO
	pelian.kabelfoon.nl" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750960AbYJ0Ilm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 04:41:42 -0400
Received: from suzy2.janevert.homelinux.org (002-008-128-083.dynamic.caiway.nl [83.128.8.2])
	by pelian.kabelfoon.nl (Postfix) with ESMTP id D0F2B427C15
	for <netdev@vger.kernel.org>; Mon, 27 Oct 2008 09:13:08 +0100 (CET)
Received: from lappie.janevert.homelinux.org ([192.168.1.115])
	by suzy2.janevert.homelinux.org with esmtp (Exim 4.63)
	(envelope-from <j.e.van.grootheest@caiway.nl>)
	id 1KuNDo-0002ox-O7
	for netdev@vger.kernel.org; Mon, 27 Oct 2008 09:13:08 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've got this old computer of a friend (to rescue files and put Ubuntu 
on it (-: ).
And there's something strange going on in the network stack somewhere.

I've booted it using an Ubuntu Hardy live CD (i.e. 2.6.24-something kernel).
There's a rtl8139 card in it that uses the 8139too module. But something 
is not right with the hardware. Dmesg is full of reports with TX ring 
pointers when I plug the cable and try to ping something.

The interesting thing is that 'ifconfig eth0' shows dropped RX packets. 
But each invocation shows one LESS dropped packet! It's never been above 
zero (that I have seen). The counter currently stands at 4294967260 
(i.e. -36).
And that's with the network cable unplugged!
This also happens when there's a whole weekend between invocations.

I did have the cable plugged in for a while. Then found out that network 
didn't work and unplugged it (had to rescue files first, so would sort 
it out later).

Now that the cable is unplugged, there are no new messages in dmesg 
about the TX ring.

I don't know whether I can reproduce this after a reboot (didn't try). 
But it's still running with the problem. So if there are requests or 
info you'd like or things you want me to try then just let me know.

(files have been rescued so I'll now be downloading Intrepid RC1 and 
check whether I can reproduce this)

Jan Evert



