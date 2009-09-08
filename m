From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: [PATCH 0/5] Adds implementation of TFRC-SP on DCCP test tree
Date: Tue, 08 Sep 2009 15:28:34 -0300
Message-ID: <4AA6A252.5060405@embedded.ufcg.edu.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from embedded.ufcg.edu.br ([150.165.63.2]:18691 "EHLO
	mail.embedded.ufcg.edu.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbZIHS2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 14:28:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to the problems in the previuos patch pointed by Gerrit Renker and all, I'm
resending the patches.


These patches adds implementation of TFRC-SP at the receiver side, and
are targeted at the DCCP branch



Patch #1: First Patch on TFRC-SP. Copy base files from TFRC
Patch #2: Implement loss counting on TFRC-SP receiver
Patch #3: Implement TFRC-SP calc of mean length of loss intervals
accordingly to section 3 of RFC 4828
Patch #4: Adds options DROPPED PACKETS and LOSS INTERVALS to receiver
Patch #5: Updating documentation accordingly


Following this patches, we'll be sending the sender side of TFRC-SP.
Once this code is integrated on the branch, we can proceed adding the
CCID4 code that uses this new TFRC-SP.

--
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab -
http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center -
http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.

