From: Dmitry Torokhov <dtor@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Fri, 25 Jan 2013 16:15:19 -0800
Message-ID: <2312112.Fz0qTjDOJB@dtor-d630.eng.vmware.com>
References: <1359135470-30677-1-git-send-email-acking@vmware.com> <1359135470-30677-2-git-send-email-acking@vmware.com> <20130125235953.GA4833@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Neil Horman <nhorman@tuxdriver.com>, acking@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: pv-drivers@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:33358 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752290Ab3AZAPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 19:15:20 -0500
In-Reply-To: <20130125235953.GA4833@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neil,

On Friday, January 25, 2013 06:59:53 PM Neil Horman wrote:
> On Fri, Jan 25, 2013 at 09:37:50AM -0800, acking@vmware.com wrote:
> > +
> > +config VMWARE_VSOCK
> > +	tristate "Virtual Socket protocol"
> > +	depends on VMWARE_VMCI
> 
> What is CONFIG_VMWARE_VMCI?  I don't find that in any Kconfig in the tree?
> 
> I''m still looking over the rest, but I get build issues if I just remove
> the dependency.

VMCI is in linux-next at the moment.

Thanks,
Dmitry
