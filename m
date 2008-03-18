From: Michel Lespinasse <walken@zoy.org>
Subject: transparent UDP proxy
Date: Tue, 18 Mar 2008 04:59:45 -0700
Message-ID: <20080318115945.GC11087@zoy.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.lespinasse.org ([64.142.28.226]:36572 "EHLO
	server.lespinasse.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbYCRMeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 08:34:17 -0400
Received: from michel.lespinasse.org (michel.home.lespinasse.org [10.1.0.1])
	by server.lespinasse.org (Postfix) with ESMTP id 9169B2FC60
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2008 04:59:45 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After redirecting UDP connections to a local port with netfilter (DNAT),
I'm trying to figure out what the original intended destination was.

For TCP sockets, I could just use the SO_ORIGINAL_DST socket option,
but that does not work with UDP (I tried, with a 2.6.22.19 kernel)

I also tried using recvmsg and looking for an IP_PKTINFO control message
as outlined in
http://lists.cistron.nl/pipermail/freeradius-users/2002-March/005600.html
but that did not work either (no anciliary data was ever received).

Is there any way to figure out the original destination IP of a NATed
UDP packet ?

Thanks,

-- 
Michel Lespinasse
