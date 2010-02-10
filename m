From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: bnx2 limits user-specified advertised speeds to one
Date: Wed, 10 Feb 2010 16:05:14 -0500
Message-ID: <4B731F8A.20508@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:8786 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755987Ab0BJVFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 16:05:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

A customer has noted that when attempting to change the advertised speeds
setting on card using a bnx2 driver, the driver advertises either all available
speeds or just one.  In other words, if a user attempts to set multiple
advertised speeds,  the settings will not be honored.

Looking at the code in bnx2_set_settings, the checks for 10baseT and 100baseT
make an assumption that the user provided only 1 speed setting.

e1000 and e1000e work correctly when the user specifies multiple advertised
speeds.

Before attempting to fix this, I wanted to ask if there was a reason for the
current functionality.

Thanks
-vlad
