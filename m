From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 0/7] [DCCP]: Further fixes and enhancements
Date: Fri, 22 Sep 2006 14:25:15 +1200
Message-ID: <200609221425.16349.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:35492 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932220AbWIVCfI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 22:35:08 -0400
Received: by nf-out-0910.google.com with SMTP id o25so922338nfa
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 19:35:07 -0700 (PDT)
To: David Miller <davem@davemloft.net>,
	"dccp (vger)" <dccp@vger.kernel.org>,
	Arnaldo de Melo <acme@mandriva.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is my latest set of patches for DCCP.

If possible I would like these to go into 2.6.19. I have tested against
2.6.18rc5 and latest net-2.6.19 git tree of Dave M as well.

Dave - Patches 1 and 2 are trivial and just introducing constants and using
them. Patch 4 is shifting some code into a header. If patch 3 could be
merged also that would be great - it is just about the same as Stephen
Hemminger's TCP Probe code but instead for DCCP. Patch 3 depends on patch 1.

I think it would be good for Arnaldo or another person to sign off on 5, 6
and 7 after a bit more of a look. These fix up packet size setting for 
CCID3 and also change them to work on half connections as you may have
different packet sizes for each. I've tested myself thoroughly but others
might have an opinion on the style of these. These three patches need to be 
applied in order.

Ian
