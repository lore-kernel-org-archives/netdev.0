From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 13:53:14 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908251351560.10062@gentwo.org>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908241334230.30487@gentwo.org> <4A930DEF.5000008@gmail.com>
 <alpine.DEB.1.10.0908250945460.5972@gentwo.org> <4A93EB9B.5020600@gmail.com> <alpine.DEB.1.10.0908250958540.28552@gentwo.org> <4A9403F0.2060301@gmail.com> <alpine.DEB.1.10.0908251135380.26329@gentwo.org> <4A940A10.60607@gmail.com> <alpine.DEB.1.10.0908251203220.26329@gentwo.org>
 <4A9410E9.6090602@gmail.com> <alpine.DEB.1.10.0908251230430.26329@gentwo.org> <4A9415F5.6020006@gmail.com> <alpine.DEB.1.10.0908251258000.26329@gentwo.org> <4A941AA6.5070506@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:45983 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755439AbZHYRxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 13:53:38 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1751E82CFBC
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 13:54:34 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id uG9RSXw4Q2rV for <netdev@vger.kernel.org>;
	Tue, 25 Aug 2009 13:54:34 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C5EB282CFCE
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 13:54:07 -0400 (EDT)
In-Reply-To: <4A941AA6.5070506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Manpage for send says:

ENOBUFS
              The output queue for a network interface was full.  This generally indicates that  the  interface  has  stopped
              sending, but may be caused by transient congestion.  (Normally, this does not occur in Linux.  Packets are just
              silently dropped when a device queue overflows.)


So ENOBUFS seems to be designed to have the role that you envision. We
just need to remove the statement in (). Its still a change in behavior
though.




