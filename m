From: Wolfgang Nothdurft <Wolfgang.Nothdurft@linogate.de>
Subject: 2.4.35-pre1: new e1000 driver breaks old hardware
Date: Fri, 15 Jun 2007 09:26:49 +0200
Message-ID: <46723F39.1000808@linogate.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linogate.de ([213.179.141.2]:2705 "EHLO mail.linogate.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751186AbXFOHiK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 03:38:10 -0400
Received: from riab.mowin.de (support.linogate.de [213.179.141.14] (may be forged))
	by mail.linogate.de with ESMTP id l5F7R7xt010514
	for <netdev@vger.kernel.org>; Fri, 15 Jun 2007 09:27:07 +0200
Received: from [192.168.0.163] ([192.168.0.163])
	by riab.mowin.de with ESMTP id l5F7QbEW016831
	for <netdev@vger.kernel.org>; Fri, 15 Jun 2007 09:26:41 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

with the new e1000 driver version 7.3.20 the onboard gigabit nic 82547EI
(8086:1019) doesn't work correctly.
After transferring about 100 megabytes over a gigabit link the transfer
stopped and I have to reinit the link either by doing a ifconfig down/up
or unplugging the network cable.
The RxIntDelay is set to 0 like described in the docu. Playing with this
Parameter only increases the amount of traffic to be send and the error
occurs later.
This happens also with the 7.4.35 and 7.5.5 driver from the intel side.
The driver 5.7.6 from kernel 2.4.33.3 and the 6.1.16 from intel works
very well on this hardware.
Also other gigabit nics we use didn't have this problem.
Is this issue already known?
Is there any solution yet?

Kind regards
Wolfgang
