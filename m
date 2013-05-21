From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 0/2] Xen network: split event channels support
Date: Tue, 21 May 2013 09:00:40 +0100
Message-ID: <20130521080040.GA11421@zion.uk.xensource.com>
References: <1369090931-27306-1-git-send-email-wei.liu2@citrix.com>
 <20130520.232752.896794972508019827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <ian.campbell@citrix.com>,
	<konrad.wilk@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:51902 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673Ab3EUIAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 04:00:43 -0400
Content-Disposition: inline
In-Reply-To: <20130520.232752.896794972508019827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 20, 2013 at 11:27:52PM -0700, David Miller wrote:
> 
> If you use the same exact subject line in all of your patches in the
> series, nobody reading the shortlog can tell what's different about
> them.
> 
> You absolutely must resubmit this with more descriptive subject lines
> which more accurately describe what each patch uniquely does.

I'm not sure I get what you mean. Their subject lines look alike, but
not exactly the same.

So this patch set adds a new feature to Xen network device, which is
called split event channels. The subject lines of two patches, one for
frontend and one for backend, speak for themselves.

No matter how I change the subject lines, they will probably still look
alike except for the leading "xen-netfront / xen-netback".  I can squash
them into one changeset if that better suits your workflow, but it is
better to leave them separate IMHO so that we can test them separately.

Advice welcomed.

Thanks
Wei.
