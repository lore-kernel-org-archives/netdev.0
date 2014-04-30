From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V7 net-next 4/7] xen-netback: Correctly clean up after
 queue initialisation error.
Date: Wed, 30 Apr 2014 15:49:54 +0100
Message-ID: <20140430144954.GA19082@zion.uk.xensource.com>
References: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>
 <1398778035-26233-5-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:39381 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933685AbaD3Otz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2014 10:49:55 -0400
Content-Disposition: inline
In-Reply-To: <1398778035-26233-5-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 02:27:12PM +0100, Andrew J. Bennieston wrote:
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> Multiple queues were introduced in the previous patch, but if the
> initialisation of a queue failed, earlier queues would not be cleaned
> up. This patch adds cleanup logic for this scenario, making use of code
> from the regular teardown sequence.
> 

Shouldn't this patch be folded into that "previous patch" which
introduced this problem? I see you did this for netfront patch already.

Wei.
