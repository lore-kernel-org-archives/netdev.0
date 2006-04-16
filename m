From: Ulrich Kunitz <kune@deine-taler.de>
Subject: softmac: semantics of SIOCSIWFREQ
Date: Sun, 16 Apr 2006 13:24:42 +0200 (CEST)
Message-ID: <Pine.LNX.4.58.0604161302270.18618@p15091797.pureserver.info>
References: <1141928917.26954.7.camel@localhost.localdomain>
 <1141935893.28038.2.camel@localhost.localdomain>  <441091B8.4010103@lwfinger.net>
  <1141936896.28038.6.camel@localhost.localdomain>  <1144886208.4187.26.camel@localhost>
  <20060413001909.GB23116@falcon.fugal.net>  <1144887916.4187.28.camel@localhost>
  <20060413002816.GC23116@falcon.fugal.net>  <1144888334.4187.32.camel@localhost>
  <20060414010545.GA10636@falcon.fugal.net> <1145129105.6560.2.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:56507 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1750716AbWDPLZT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 07:25:19 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1145129105.6560.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm just reviewing the zd1211 code and I'm wondering about the
semantics of SIOCSIWFREQ and actually, what is good for. It looks
like that softmac's set_channel can be called at any time and will
ignore any settings of SIOCSIWFREQ even it is has been given the
flag IW_FREQ_FIXED. 

Following questions come to mind:

- Is SIOCSIWFREQ allowed while associated?
- If the flag IW_FREQ_FIXED is set, should all activitity
  including scanning only be allowed on this frequency? (Actually
  a better would even be to work with channel/frequency sets.
  These sets would make a lot of sense for parallel scanning
  whith more than one device.)
- Is there any use of the control, if the frequency is not fixed?

SIOCSIWFREQ and SIOCGIWFREQ appear to be good candidates to be
included in the softmac. If I would have a rough idea, what the
semantics should be, I would even volunteer to implement it. 

Uli

-- 
Ulrich Kunitz - kune@deine-taler.de
