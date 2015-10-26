From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V3 1/2] xen-netback: limit xen vif max queues number to
 online cpus
Date: Mon, 26 Oct 2015 14:54:21 +0000
Message-ID: <20151026145421.GJ13118@zion.uk.xensource.com>
References: <562A0108.3070501@oracle.com> <562A018C.9060708@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <wei.liu2@citrix.com>, Ian Campbell <ian.campbell@citrix.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Jan Beulich" <JBeulich@suse.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:52709 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbbJZOyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 10:54:24 -0400
Content-Disposition: inline
In-Reply-To: <562A018C.9060708@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 05:44:44PM +0800, Joe Jin wrote:
> Should not allocate xen vif queues number more than online cpus.

I think it's absolutely fine for administrators to override the value
should they choose to.

Wei.
