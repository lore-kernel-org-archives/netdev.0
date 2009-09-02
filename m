From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: [PATCH 0/5] Adds implementation of TFRC-SP on DCCP test tree
Date: Tue, 1 Sep 2009 23:43:44 -0300
Message-ID: <cb00fa210909011943s656fbadfo95132dc2fba0d73c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: dccp <dccp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f181.google.com ([209.85.210.181]:39322 "EHLO
	mail-yx0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544AbZIBCoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 22:44:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
