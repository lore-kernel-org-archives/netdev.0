From: Phil Oester <kernel@linuxace.com>
Subject: bonding + igb TX queue warnings
Date: Wed, 2 Feb 2011 07:55:56 -0800
Message-ID: <20110202155556.GA5127@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45547 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754360Ab1BBP4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 10:56:02 -0500
Received: by gyb11 with SMTP id 11so42881gyb.19
        for <netdev@vger.kernel.org>; Wed, 02 Feb 2011 07:56:02 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running 2.6.36.3 here, and brought up a bond on 2 igb interfaces.
Syslog now getting flooded with this:

kernel: bond0 selects TX queue 16, but real number of TX queues is 16

Any way to change which queue bond0 is selecting or otherwise fix
this?

Phil
