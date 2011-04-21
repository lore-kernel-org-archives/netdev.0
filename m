From: Marco Chiappero <marco@absence.it>
Subject: rfkill-input to be removed
Date: Thu, 21 Apr 2011 10:28:23 +0200
Message-ID: <4DAFEAA7.5090003@absence.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aa012-1msr.fastwebnet.it ([62.101.93.132]:60501 "EHLO
	aa012-1msr.fastwebnet.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753504Ab1DUI21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 04:28:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While working on the the sony-laptop driver, adding support for 
persistent rfkill state storing and adding the SW_RFKILL_ALL switch 
event forwarding to the input core to notify userspace, I realized that 
rfkill-input interferes with correct behavior of the driver, vanishing 
the hardware device state storing. Then, looking at 
Documentation/feature-removal-schedule.txt I realized that rfkill-input 
was scheduled to be removed in 2.6.33, but it's still there in 2.6.39. 
Please remove that code as soon as possible, rfkill input events should 
be handled by user space tools.
