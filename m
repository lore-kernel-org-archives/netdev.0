From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net] xen-netback: fix abuse of napi budget
Date: Tue, 10 Dec 2013 10:34:08 +0000
Message-ID: <20131210103408.GI32155@zion.uk.xensource.com>
References: <1386670600-5882-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:12431 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939Ab3LJKeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 05:34:09 -0500
Content-Disposition: inline
In-Reply-To: <1386670600-5882-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 10:16:40AM +0000, Paul Durrant wrote:
> netback seemed to be somewhat confused about the napi budget parameter and
> basically ignored it. This patch fixes that, properly limiting the work done
> in each poll.
> 

After reading the code I think your "basically ignored it" means netback
will process the ring as much as possible, right? 

But overall the packets passed to network stack is still limited by
budget, if I'm not mistaken.

What's the impact on flow control if you more the check earlier?

Wei.
