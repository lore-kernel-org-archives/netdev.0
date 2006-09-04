From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Paper on lookup in Linux.
Date: Mon, 4 Sep 2006 15:54:27 +0200
Message-ID: <17660.12307.406524.613346@robur.slu.se>
References: <17660.4445.36266.884445@robur.slu.se>
	<200609041424.26564.ak@suse.de>
	<17660.8632.602340.514616@robur.slu.se>
	<200609041529.39688.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@vger.kernel.org,
	snilsson@nada.kth.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:48331 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S1751344AbWIDNya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 09:54:30 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200609041529.39688.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andi Kleen writes:

 > The reason I'm asking is that we still have trouble with the TCP hash tables
 > taking far too much memory, and your new data structure might provide a nice 
 > alternative. 

 Yes it's dynamic and selftuning so no need reserve memory in advance and still 
 comparable performance to a perfect hash. Insert/delete and GC is fast and 
 locking is also doable we used RCU like fib_trie but at _bh in this "application". 
 
 Cheers.
						--ro
