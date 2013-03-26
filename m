From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: defxx: skb_push() failing?
Date: Tue, 26 Mar 2013 19:00:30 +0000 (GMT)
Message-ID: <alpine.LFD.2.03.1303261852220.8240@linux-mips.org>
References: <5151B0CE.5000000@ll.mit.edu>  <1364310900.1716.21.camel@edumazet-glaptop> <5151C6C3.6090408@ll.mit.edu> <1364315410.1716.40.camel@edumazet-glaptop> <5151ECAC.9040404@ll.mit.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Oostdyk <daveo@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:49557 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236Ab3CZTIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 15:08:39 -0400
Received: from localhost.localdomain ([127.0.0.1]:44480 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6826577Ab3CZTAatSuJB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 20:00:30 +0100
In-Reply-To: <5151ECAC.9040404@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Mar 2013, David Oostdyk wrote:

> (Now if I could only figure out why these FDDI cards don't want to talk to
> each other... I was hoping that was it.)

 I saw 64-bit addresses in your log -- the driver is known not to be 
64-bit-clean, I've had an initial look into it recently and will be 
addressing it shortly.

  Maciej
