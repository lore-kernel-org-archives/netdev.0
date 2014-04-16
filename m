From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH] drivers: net: xen-netfront: remove unused
 arrays
Date: Wed, 16 Apr 2014 09:26:38 +0100
Message-ID: <1397636798.24638.117.camel@kazak.uk.xensource.com>
References: <1397583579-32162-1-git-send-email-v.maffione@gmail.com>
	 <534D7244.5000002@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vincenzo Maffione <v.maffione@gmail.com>,
	<xen-devel@lists.xenproject.org>, <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <534D7244.5000002@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-04-15 at 18:54 +0100, David Vrabel wrote:
> On 15/04/14 18:39, Vincenzo Maffione wrote:
> > This patch removes some unused arrays from the netfront
> > private data structure.
> > Also removes an unused address variable.
> > 
> > Signed-off-by: Vincenzo Maffione <v.maffione@gmail.com>
> 
> Huh. I wonder what they were for.

Looks like they were leftovers from the old flipping mode of operation.
Which was removed with:
        commit 5dcddfae63bd26da0f11a8e40f0ae555b5ac624e
        Author: Jeremy Fitzhardinge <jeremy@goop.org>
        Date:   Tue Aug 7 14:56:42 2007 -0700
        
            xen-netfront: remove dead code
        
Which missed these bits.
Ian.

> Acked-by: David Vrabel <david.vrabel@citrix.com>
> 
> For net related patches please say whether they're for the net (current
> RCs) or net-next branch.  e.g.,
> 
> [PATCH net-next] xen-netfront: removed unused arrays.
> 
> Thanks.
> 
> David
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
