From: Shrikrishna Khare <skhare@vmware.com>
Subject: Re: [Pv-drivers] [PATCH net v2] vmxnet3: segCnt can be 1 for LRO
 packets
Date: Wed, 8 Jun 2016 07:43:16 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1606080741541.14228@shri-linux.eng.vmware.com>
References: <1465366415-124072-1-git-send-email-skhare@vmware.com> <5757EEFC.3060709@vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, Jin Heo <heoj@vmware.com>
To: Thomas Hellstrom <thellstrom@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:53015 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423479AbcFHOnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 10:43:18 -0400
In-Reply-To: <5757EEFC.3060709@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 8 Jun 2016, Thomas Hellstrom wrote:

> >  				mss = rcdlro->mss;
> >  				if (unlikely(segCnt <= 1))
> >  					segCnt = 0;
> 
> Based on this code, it looks like it can handle the case without taking
> down the kernel completely, so instead of a
> "BUG_ON", would it make sense with a WARN_ON_ONCE() or WARN_ON()?

Thanks for the review Thomas. I fixed the code to use WARN_ON_ONCE. Sent 
out revised patch.
