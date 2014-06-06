From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next] bridge: Fix incorrect judgment of promisc
Date: Fri, 6 Jun 2014 08:48:48 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725853E@AcuExch.aculab.com>
References: <1401969212-19193-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <20140605.152151.1874961526019573838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>
To: 'David Miller' <davem@davemloft.net>,
	"makita.toshiaki@lab.ntt.co.jp" <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37336 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751390AbaFFItV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 04:49:21 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10196-09 for <netdev@vger.kernel.org>;
 Fri,  6 Jun 2014 09:49:11 +0100 (BST)
In-Reply-To: <20140605.152151.1874961526019573838.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller [mailto:davem@davemloft.net]
> > br_manage_promisc() incorrectly expects br_auto_port() to return only 0
> > or 1, while it actually returns flags, i.e., a subset of BR_AUTO_MASK.
> >
> > Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> 
> I'm applying this as-is for now, even though I saw the other
> suggestions in this thread (which BTW didn't get picked up by
> patchwork, maybe some of you dropped the Message-Id in your replies by
> accident).

I don't have a problem with that.
The condition looks odd, but it is enabling promiscuous mode
if any other ports are in 'auto' mode.
Possibly the comment above made that clear, but it was truncated
in the diffs.

	David
