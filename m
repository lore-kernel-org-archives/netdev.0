From: "Bandi,Sarveshwar" <Sarveshwar.Bandi@Emulex.Com>
Subject: RE: Patch for stable: bridge: Pull ip header into skb->data before
 looking into ip header.
Date: Tue, 15 Jan 2013 21:36:24 +0000
Message-ID: <9f30b203-f14e-40c6-b13d-2532cb6d72f9@CMEXHTCAS1.ad.emulex.com>
References: <9D1F9FE58F08ED47AA451ABB038550E91FEB7EB1@CMEXMB2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Bandi,Sarveshwar" <Sarveshwar.Bandi@Emulex.Com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:4114 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757045Ab3AOVga convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 16:36:30 -0500
In-Reply-To: <9D1F9FE58F08ED47AA451ABB038550E91FEB7EB1@CMEXMB2.ad.emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,
  Did you miss this? Or this is there a different process to request this?

Thanks,
Sarvesh

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Bandi,Sarveshwar
Sent: Friday, January 11, 2013 12:29 PM
To: davem@davemloft.net
Cc: netdev@vger.kernel.org
Subject: Patch for stable: bridge: Pull ip header into skb->data before looking into ip header.

Dave,
  Can you please queue the following patch for linux 3.x stable trees?

commit 6caab7b0544e83e6c160b5e80f5a4a7dd69545c7
Author: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
Date:   Wed Oct 10 01:15:01 2012 +0000

    bridge: Pull ip header into skb->data before looking into ip header.

    If lower layer driver leaves the ip header in the skb fragment, it needs to
    be first pulled into skb->data before inspecting ip header length or ip version
    number.

    Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks,
Sarvesh


--
To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
