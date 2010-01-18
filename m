From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH 1/1] sched: add head drop fifo queue
Date: Mon, 18 Jan 2010 20:59:08 +0100
Message-ID: <20100118195907.GI16482@nuttenaction>
References: <4B548DAE.3000205@trash.net>
 <1263833050-11635-1-git-send-email-hagen@jauu.net>
 <4B54B59D.5010108@gmail.com>
 <20100118193645.GH16482@nuttenaction>
 <20100118195100.GB3157@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57481 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751282Ab0ART7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 14:59:10 -0500
Content-Disposition: inline
In-Reply-To: <20100118195100.GB3157@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jarek Poplawski | 2010-01-18 20:51:00 [+0100]:

>Did you test it? IMHO "sch->q.qlen--" is done 2 times.

The test setup was a little but cumbersome, but yes. But you are right, good
catch: qlen-- via __skb_unlink(). Thank you!

HGN

-- 
Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://jauu.net/
Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22
