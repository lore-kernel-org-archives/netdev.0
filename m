From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2] xen-netback: implement dynamic multicast
 control
Date: Tue, 2 Feb 2016 11:46:46 +0000
Message-ID: <20160202114646.GF10990@citrix.com>
References: <1454412668-6472-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:62615 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754710AbcBBLqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 06:46:48 -0500
Content-Disposition: inline
In-Reply-To: <1454412668-6472-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 02, 2016 at 11:31:08AM +0000, Paul Durrant wrote:
[...]
> +static int xen_register_mcast_ctrl_watch(struct xenbus_device *dev,
> +					 struct xenvif *vif)
> +{
> +	int err = 0;
> +	char *node;
> +	unsigned maxlen = strlen(dev->otherend) +
> +		sizeof("/request-multicast-control");
> +
> +	if (vif->mcast_ctrl_watch.node)
> +		return -EADDRINUSE;
> +

Sorry if I didn't make myself clear enough. I think EADDRINUSE should
also be logged.

Wei.
