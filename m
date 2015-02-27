From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Question: should local address be expired when updating PMTU?
Date: Fri, 27 Feb 2015 11:32:57 +0100
Message-ID: <20150227103256.GC20631@secunet.com>
References: <54CF3348.40207@huawei.com>
 <20150203092845.GT13046@secunet.com>
 <54D0A8DB.4010106@huawei.com>
 <20150203120140.GU13046@secunet.com>
 <54D17D1A.3020706@huawei.com>
 <20150205072125.GY13046@secunet.com>
 <54EFD87A.5080907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<yangyingliang@huawei.com>, <hannes@redhat.com>
To: shengyong <shengyong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44397 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433AbbB0KdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2015 05:33:00 -0500
Content-Disposition: inline
In-Reply-To: <54EFD87A.5080907@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 10:37:46AM +0800, shengyong wrote:
> Hi, Steffen
> Is this patchset ready? It seems that I didn't find it in the mainling
> list. If it is ready, I can test it to see if it solves the problem I
> met :)

Martin Lau pointed me to a problem when cached host routes are deleted.
We may delete the clone but not the original route. This has to be
resolved first. Unfortunately I had no time to look into this so far.
I hope to get to it next week.
