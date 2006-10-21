From: Pawel Foremski <pjf@asn.pl>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Sat, 21 Oct 2006 17:12:16 +0200
Message-ID: <ehddcg$2f5$1@sea.gmane.org>
References: <200610151820.22867.dpc@asn.pl> <17717.40394.531846.695392@localhost.localdomain> <200610181115.12471.dpc@asn.pl> <17718.63424.509719.492216@localhost.localdomain> <eh87aq$71t$1@sea.gmane.org> <17720.12801.843076.819750@localhost.localdomain> <ehbava$iia$1@sea.gmane.org> <17721.32425.591879.97484@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:55994 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1423349AbWJUPMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2006 11:12:33 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GbIWQ-0006v9-Cf
	for netdev@vger.kernel.org; Sat, 21 Oct 2006 17:12:26 +0200
Received: from demiurg.asn.pl ([85.14.84.18])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2006 17:12:26 +0200
Received: from pjf by demiurg.asn.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2006 17:12:26 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen J. Bevan wrote:

> However, in the above you note that MPPE is being used.  I take this
> to mean that all the PPP traffic between the PPPoE client and PPPoE
> server is encrypted.  However, if that's the case then I don't
> understand why there is a need to use ccrypt for the wireless link
> between the two Linux boxes.  Thus perhaps I misunderstood where MPPE
> is being used?  Or perhaps you meant this is only one example and in
> other scenarios MPPE is not used and so in that case the wireless
> traffic does need encrypting?

For example because MPPE is optional and some sessions may be encrypted and
some not. As I mentioned, we cannot influence the ISP in topic.

More generally, I wanted to present an example of a layer-2 encapsulation
that Linux does not know or (as in this case) can't modify the data in it,
thus it cannot fix the TCP MSS value.

-- 
Pawel Foremski
pjf@asn.pl

