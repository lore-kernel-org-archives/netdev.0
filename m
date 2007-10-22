From: "Michael Whyte" <m.whyte@gmail.com>
Subject: CC2420 (802.15.4) Speed Issue
Date: Mon, 22 Oct 2007 10:47:13 +1000
Message-ID: <177fe7690710211747p23156475m9e880da04e1574c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:36624 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbXJVArO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 20:47:14 -0400
Received: by py-out-1112.google.com with SMTP id u77so2127576pyb
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2007 17:47:14 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guys,

I'm currently writing my first bit of Linux kernel code so be gentle.
It's a driver for TI CC2420 802.15.4 radio and I'm observing strange
behavior. I am currently testing just by transferring a ~300kb file
over HTTP between two of these devices.

The strange thing is, when ever you start the transfer it starts
humming along at 5k/s which is not far off what I'd expect these
devices to achieve, then at some random point along the transfer or
sometimes not at all... it suddenly drops fairly deterministically to
150byte/s and finishes the transfer at that speed, maybe rising to
170bytes/s by the end of the transfer is I'm lucky.

I don't really know where to start looking to solve the problem, it
seems everything is functioning as it should at least some of the time
as in some cases it will complete the whole transfer at the 5k/s
speed. Is it just tcp throttling very harshly (i.e. 50x) when it loses
a packet? Is it the Xscale chip scaling down the CPU frequency
mid-transfer, I've got no idea how to check this? It is some sort of
resonance affect happening with the two radios CCA although I'm not
seeing any CCA timeouts.

Can any one give any hints what to play with or where to look to try
find the cause and get the transfers to run reliabily without the
sudden bottoming out of speeds? (if you stop the transfer and initiate
a new one immediately it will start at full speed again)

Thanks,
-YT
