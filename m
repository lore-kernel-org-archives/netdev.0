From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 1 Sep 2009 22:24:32 +0200
Message-ID: <20090901202432.GA3200@ami.dom.local>
References: <20090901063726.GA5222@ff.dom.local>
 <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1>
 <4A9D2DBF.8030200@trash.net>
 <4A9D3687.2020101@gmail.com>
 <alpine.DEB.1.10.0909011504030.12112@V090114053VZO-1>
 <4A9D3D9A.1030500@gmail.com>
 <alpine.DEB.1.10.0909011534350.12112@V090114053VZO-1>
 <4A9D410D.5000507@gmail.com>
 <4A9D448D.6050309@gmail.com>
 <alpine.DEB.1.10.0909011753230.25607@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:53819 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754914AbZIAUY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 16:24:56 -0400
Received: by bwz19 with SMTP id 19so280492bwz.37
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2009 13:24:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909011753230.25607@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2009 at 05:55:44PM -0400, Christoph Lameter wrote:
> 
> Ok i got some meaningful statistics now. Why is the qlen zero for all
> devices?

Looks like it's updated with q->q.qlen before dumps only. Nice work!
Btw, isn't there something with your localhost's time?

Original-Received: from ...
	...
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 13:58:12 -0400 (EDT)
Original-Received: from cl (helo=localhost)
	...
	id 1MibKK-0007nd-Ib; Tue, 01 Sep 2009 17:55:44 -0400

Jarek P.
