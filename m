From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 issues
Date: Fri, 20 Jul 2007 12:34:21 -0700
Message-ID: <1184960061.4850.9.camel@dell>
References: <469E78A2.80904@imperialnet.org>
 <366312910707190419se33ddd2o3870b5684e077276@mail.gmail.com>
 <20070719113755.GA1934@hmsreliant.homelinux.net>
 <469F6601.20800@imperialnet.org> <1184866465.10854.45.camel@dell>
 <46A0E9D7.7020904@imperialnet.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Neil Horman" <nhorman@tuxdriver.com>,
	"netdev" <netdev@vger.kernel.org>
To: "patric" <pakar@imperialnet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1065 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753272AbXGTSl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 14:41:27 -0400
In-Reply-To: <46A0E9D7.7020904@imperialnet.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-07-20 at 18:59 +0200, patric wrote:

> Thanks... That's a confirmation on what i  suspected.. I think i'll dig 
> into the code instead and try to figure out some way of making it work a 
> bit better for my setup atleast...
> I'll post a patch later if i get something working... Btw, do you have 
> any timings on how long it takes for the cards to get a lock on the link?
> 

Serdes link comes up very fast.  The clause 37 autoneg involves going
through a few states and exchanging base pages and optional next pages.
Each state completes in 10 msec, so the whole autoneg should complete in
roughly 100 msec or so.  But because it is done in software for these
older cards, it can take much longer because it can get out-of-sync. 

