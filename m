From: Peter Fassberg <pf@leissner.se>
Subject: Default network namespace name
Date: Wed, 21 May 2014 08:36:40 +0200 (SST)
Message-ID: <alpine.BSF.2.00.1405210826570.47766@nic-i.leissner.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgate.leissner.se ([212.3.1.210]:64777 "EHLO
	mailgate.leissner.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbaEUGuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 02:50:32 -0400
Received: from mailgate.leissner.se (localhost [127.0.0.1])
	by mailgate.leissner.se (8.14.8/8.14.8) with ESMTP id s4L6akPA097601
	for <netdev@vger.kernel.org>; Wed, 21 May 2014 08:36:46 +0200 (CEST)
	(envelope-from pf@leissner.se)
Received: (from uucp@localhost)
	by mailgate.leissner.se (8.14.8/8.14.8/Submit) id s4L6akEQ097596
	for <netdev@vger.kernel.org>; Wed, 21 May 2014 08:36:46 +0200 (CEST)
	(envelope-from pf@leissner.se)
Received: from nic-i.leissner.se (localhost [127.0.0.1])
	by nic-i.leissner.se (8.14.8/8.14.7) with ESMTP id s4L6aeio098486
	for <netdev@vger.kernel.org>; Wed, 21 May 2014 08:36:40 +0200 (CEST)
	(envelope-from pf@leissner.se)
Received: from localhost (pf@localhost)
	by nic-i.leissner.se (8.14.8/8.14.7/Submit) with ESMTP id s4L6aegT098483
	for <netdev@vger.kernel.org>; Wed, 21 May 2014 08:36:40 +0200 (CEST)
	(envelope-from pf@leissner.se)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi!

Is there a name of the default network namespace?

I would like to execute a command in the default network namespace while running a shell in a non-default namespace.

Like this: ip netns exec "" ip link
Or this:   ip netns exec . ip link

That command end up with a mis-spelled error message: :)
seting the network namespace "" failed: Invalid argument



Regards,

Peter
