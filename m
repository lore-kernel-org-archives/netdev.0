From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Subject: atl1c not doing any network traffic on eeepc 1008HA.
Date: Wed, 10 Jun 2009 19:31:10 -0400
Message-ID: <20090610233110.GA17112@taurine.csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:59676 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752876AbZFJXbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 19:31:08 -0400
Received: from caffeine.csclub.uwaterloo.ca (localhost [127.0.0.1])
	by caffeine.csclub.uwaterloo.ca (Postfix) with ESMTP id 2750373E1B
	for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 19:31:11 -0400 (EDT)
Received: from taurine (taurine.csclub.uwaterloo.ca [129.97.134.34])
	by caffeine.csclub.uwaterloo.ca (Postfix) with SMTP id 1135373DD6
	for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 19:31:10 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My wife just got an eeepc 10008HA a week ago, and so far Debian
unstable is runnig quite well on it.  Wifi works fine for example.
Wired networking however does not.  The atl1c driver loads and detects
the network port, but no traffic ever manages to make it through.
dmesg seems to indicate that the PHY has link, but there doesn't seem
to be any indication of that in ip link or ifconfig on the other hand.

Any suggestions on where to go about gatharing debug info for this?

Right now it is running the 2.6.29-2-686 kernel from Debian which I
believe is 2.6.29.3 based at the moment.

I will try to get a hold of the dmesg output from the machine.

-- 
Len Sorensen
