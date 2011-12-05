From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [net-next 1/6] e1000e: Avoid wrong check on TX hang
Date: Mon, 5 Dec 2011 11:49:56 -0200
Message-ID: <20111205114956.439c00bc@asterix.rh>
References: <1323073241-21144-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1323073241-21144-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<4EDC82AE.40806@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932151Ab1LENuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 08:50:05 -0500
In-Reply-To: <4EDC82AE.40806@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 05 Dec 2011 16:37:02 +0800
Michael Wang <wangyun@linux.vnet.ibm.com> wrote:

> Hi, Jeff
> 
> Please reserve "From: Michael Wang <wangyun@linux.vnet.ibm.com>" in
> content. And because Flavio not respond these days, I add his name
> for him.
> 
> Thanks,
> Michael Wang
> 
> On 12/05/2011 04:20 PM, Jeff Kirsher wrote:
> 
> > Based on the original patch submitted my Michael Wang
> > <wangyun@linux.vnet.ibm.com>.
> 
> From: Michael Wang <wangyun@linux.vnet.ibm.com>
> 
> > Descriptors may not be write-back while checking TX hang with flag
> > FLAG2_DMA_BURST on.
> > So when we detect hang, we just flush the descriptor and detect
> > again for once.
> > 
> > -v2 change 1 to true and 0 to false and remove extra ()
> > 
> > CC: Michael Wang <wangyun@linux.vnet.ibm.com>
> > CC: Flavio Leitner <fbl@redhat.com>
> 
> Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>

Agree with the fixes. thanks,
Signed-off-by: Flavio Leitner <fbl@redhat.com>
