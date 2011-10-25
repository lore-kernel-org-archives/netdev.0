From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next-2.6 PATCH 0/8 RFC v2] macvlan: MAC Address filtering
 support for passthru mode
Date: Tue, 25 Oct 2011 17:46:18 +0200
Message-ID: <20111025154617.GB22553@redhat.com>
References: <20111024054710.GB24528@redhat.com>
 <CACAF939.37AAD%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sri@us.ibm.com, dragos.tatulea@gmail.com,
	arnd@arndb.de, kvm@vger.kernel.org, davem@davemloft.net,
	mchan@broadcom.com, dwang2@cisco.com, shemminger@vyatta.com,
	eric.dumazet@gmail.com, kaber@trash.net, benve@cisco.com,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55596 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756680Ab1JYPqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Oct 2011 11:46:23 -0400
Content-Disposition: inline
In-Reply-To: <CACAF939.37AAD%roprabhu@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 24, 2011 at 11:15:05AM -0700, Roopa Prabhu wrote:
> >> ... And also I dont know of any hw
> >> that provides an interface to set hw filters on a per queue basis.
> > 
> > VMDq hardware would support this, no?
> > 
> Am not really sure. This patch uses netdev to pass filters to hw. And I
> don't see any netdev infrastructure that would support per queue filters.

Sure. I was only saying that as far as I understand,
VMDq hardware does support this functionality.
Right, Greg?

-- 
MST
