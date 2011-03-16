From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: No iproute2 for 2.6.38
Date: Tue, 15 Mar 2011 22:46:37 -0700
Message-ID: <4D804EBD.4030904@us.ibm.com>
References: <20110315195534.0cc43032@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:52771 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751349Ab1CPFqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2011 01:46:38 -0400
In-Reply-To: <20110315195534.0cc43032@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/2011 7:55 PM, Stephen Hemminger wrote:
> I am not going to bother releasing for 2.6.38 the only changes
> were later reverted.
2.6.38 includes support for macvlan/macvtap 'passthru' mode that allows 
assigning
SR-IOV VFs to a KVM guest via macvtap/virtio.
It is not possible to support live migration using direct assignment of 
VF's to a guest,
but 'passthu' assignment makes this possible.

Enabling this feature requires the following patch to iproute2 that 
allows creating macvlan
device in 'passthru' mode.
     http://patchwork.ozlabs.org/patch/69515/
Looks like this patch is still marked as 'Awaiting upstream'.

Could you apply this patch and it would be great if a version of 
iproute2 is released for 2.6.38.

Thanks
Sridhar

> ---
> Roopa Prabhu (1):
>        iproute2: add VF_PORT support
>
> Stephen Hemminger (3):
>        Update to lasest kernel headers
>        Revert "iproute2: add VF_PORT support"
>        v2.6.38
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


