From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [RFD] dccp: Rate Mismatch Controller -- still requires high-res
	timers?
Date: Mon, 9 Aug 2010 12:54:55 +0200
Message-ID: <20100809105454.GA3591@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ldecicco.gmail.com@gerrit.erg.abdn.ac.uk
To: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Ivo Calado <ivocalado@embedded.ufcg.edu.br>,
	Leandro <leandroal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:36831 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756076Ab0HIK6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Aug 2010 06:58:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have finished a simple proof-of-concept implementation of the Rate Mismatch Controller for TFRC and put the patches/results on
  
  http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3/sender_notes/rate_mismatch_controller/

The results are not as good as had been hoped - in particular, it still seems
necessary to use high-res timers in order to achieve reasonable stability and
accuracy.

Perhaps I have missed something, but as it stands, I can not see an advantage
in using this for TFRC - comments welcome.

Gerrit
