From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next 0/2] Xen network: split event channels support
Date: Tue, 21 May 2013 09:17:35 +0100
Message-ID: <1369124255.21246.19.camel@zakaz.uk.xensource.com>
References: <1369090931-27306-1-git-send-email-wei.liu2@citrix.com>
	 <20130520.232752.896794972508019827.davem@davemloft.net>
	 <20130521080040.GA11421@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:11086 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab3EUIRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 04:17:37 -0400
In-Reply-To: <20130521080040.GA11421@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 09:00 +0100, Wei Liu wrote:
> On Mon, May 20, 2013 at 11:27:52PM -0700, David Miller wrote:
> > 
> > If you use the same exact subject line in all of your patches in the
> > series, nobody reading the shortlog can tell what's different about
> > them.
> > 
> > You absolutely must resubmit this with more descriptive subject lines
> > which more accurately describe what each patch uniquely does.
> 
> I'm not sure I get what you mean. Their subject lines look alike, but
> not exactly the same.
> 
> So this patch set adds a new feature to Xen network device, which is
> called split event channels. The subject lines of two patches, one for
> frontend and one for backend, speak for themselves.

This is true, but I wonder if peoples eyes tend to skip over the initial
prefix.

> No matter how I change the subject lines, they will probably still look
> alike except for the leading "xen-netfront / xen-netback".  I can squash
> them into one changeset if that better suits your workflow, but it is
> better to leave them separate IMHO so that we can test them separately.
>
> Advice welcomed.

How about "xen-netback: Split event channel support for Xen Backend
driver" and the equivalent for frontend? 

I'd prefer to keep it as two changesets if possible.

Ian.
