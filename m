From: Jean Delvare <jdelvare@suse.de>
Subject: bonding with 3c59x driver
Date: Mon, 13 Feb 2012 22:53:16 +0100
Message-ID: <201202132253.16496.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41704 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639Ab2BMVxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:53:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen, all,

I am trying to do network bonding on top of 3com 3C905C ethernet 
adapters. I am facing the problem that network cable removal isn't 
detected. It is detected when using Realtek hardware with driver 8139too 
or VIA hardware with driver via-rhine, but no luck with driver 3c59x. 
I'm using bonding option miimon=100 for link detection.

Does anyone know if this is a hardware limitation, or a missing feature 
of the 3c59x driver, or a bug in that driver?

Thanks,
-- 
Jean Delvare
Suse L3
