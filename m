From: Ajit <ajitsa_bes@yahoo.com>
Subject: Re: Maximum no of bytes Ethernet can transfer at a time ??
Date: Thu, 28 Apr 2011 05:49:23 +0000 (UTC)
Message-ID: <loom.20110428T074300-379@post.gmane.org>
References: <loom.20110427T140651-957@post.gmane.org> <20110427130114.GA1895@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:60630 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751559Ab1D1Fti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2011 01:49:38 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QFK6a-00085E-Gt
	for netdev@vger.kernel.org; Thu, 28 Apr 2011 07:49:37 +0200
Received: from 134.snat-111-91-96.hns.net.in ([111.91.96.134])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 07:49:36 +0200
Received: from ajitsa_bes by 134.snat-111-91-96.hns.net.in with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 07:49:36 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman <at> tuxdriver.com> writes:


hii Neil,

I am not using the transport layer neither the Network layer. I have written a
small protocol which work of a LAN without a router. So ideally there is no need
of the network layer (I am using physical address for the transfer). 

I have defined a filed called as "offset" and another one called as "id".
Whenever you send a file, it is divided into various frames depending upon the
size of the file and send with the same "id" and an offset incremented by 1.

As you said the firewall issues. I don't think that is the problem because I am
sending the file to myself, but , on eth0 rather than lo, because send on lo
wont give the expected results.

If you still want some explanation then please ask me.

Thank you. 


