From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 0/7] [DCCP]: Fixes and enhancements
Date: Thu, 24 Aug 2006 15:16:33 +1200
Message-ID: <200608241516.34448.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:12560 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030234AbWHXDQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:16:46 -0400
Received: by py-out-1112.google.com with SMTP id n25so507740pyg
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 20:16:45 -0700 (PDT)
To: Andrea Bittau <a.bittau@cs.ucl.ac.uk>,
	David Miller <davem@davemloft.net>,
	Arnaldo de Melo <arnaldo.melo@gmail.com>,
	"DCCP (vger)" <dccp@vger.kernel.org>,
	"netdev, " <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please find following a series of patches for DCCP.

These have been tested against torvalds/linux-2.6.git and davem/net-2.6.19.git

My opinion is that 1 and 2 can go straight into 2.6.18 as documentation
changes only - Dave - are you able to do as Arnaldo is very busy at present.

I would love 3, 4, 5 to go into 2.6.18 as these resolve long standing CCID3
issues that have been in the DCCP tree since inception and have caught a
number of people.

Number 6 is just shifting code around to tidy it up and introduces no change
in logic. You could argue for it to go in either 2.6.18 or 2.6.19!

Number 7 is implementing transmit buffering and is 2.6.19 material.
Andrea - this might be quite useful for you in CCID2 as well I believe.

These patches are all capable of being done independently except 3, 4, 5 which
are a group.

Also on http://wand.net.nz/~iam4/dccp/patches/ are the following further
patches which are not ready for merge but others might be interested in:
-DCCP-Probe ala TCP-Probe
-The starts of memory buffer limiting (this is not actually needed for number
7 as it is actually receive where problems occur which is an existing issue)
-My research code

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
