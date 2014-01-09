From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: [net-next 05/15] i40e: add a comment on barrier and fix panic
 on reset
Date: Thu, 9 Jan 2014 09:17:35 -0800
Message-ID: <20140109091735.00002cf0@unknown>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1389271944-26227-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<52CEB538.50505@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>,
	"Mitch Williams" <mitch.a.williams@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42024 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705AbaAIRRj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 12:17:39 -0500
In-Reply-To: <52CEB538.50505@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Jan 2014 18:42:00 +0400
Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:

> Hello.
> 
> On 09-01-2014 16:52, Jeff Kirsher wrote:
> 
> > From: Greg Rose <gregory.v.rose@intel.com>
> 
> > The memory barrier used in maybe_stop_tx can use a comment.
> 
> > Also add checks to VSI->rx_rings to ensure a kernel panic is not
> > induced.
> 
>     Don't see why this is made in one patch instead of two since the
> two things look completely unrelated and even modifying different
> files.
> 
> > Change-ID: I48cc1bf1d6cf301818155b737edeef77c0d790c7
> > Change-ID: I1363a8445fbf521a26267849966296ed55f43ad8
> 
>     Why even 2 of them?
> 
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> WBR, Sergei
> 

Yes, it's apparent that two different internal patches were compressed
together.  If its unacceptable to do this then I'll speak to Jeff about
splitting them.

- Greg
