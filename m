From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v1 0/8] xen-netback: support toeplitz hashing
Date: Fri, 12 Feb 2016 16:59:01 +0000
Message-ID: <708813d655494f2785fda3bb4f83e1d9@AMSPEX02CL03.citrite.net>
References: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
	<20160212.055408.1901988218281607996.davem@davemloft.net>
	<47dcce9fc54b42f591284cd8ea72ddba@AMSPEX02CL03.citrite.net>
 <20160212.114146.557404301623026279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:24691 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbcBLRBj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 12:01:39 -0500
In-Reply-To: <20160212.114146.557404301623026279.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: 12 February 2016 16:42
> To: Paul Durrant
> Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org
> Subject: Re: [PATCH net-next v1 0/8] xen-netback: support toeplitz hashing
> 
> From: Paul Durrant <Paul.Durrant@citrix.com>
> Date: Fri, 12 Feb 2016 11:07:50 +0000
> 
> > Windows *requires* use of Teoplitz so your position completely rules
> > out being able to support receive side scaling in Windows PV
> > frontends on Linux kernel backends, not only for Xen but for any
> > other hypervisor, which I think is totally unreasonable.
> 
> We have strong reason to believe that Toeplitz has properties that
> make it very weak if not exploitable, therefore doing software RSS
> with Jenkins is superior.

I don't disagree, but there is really no choice of algorithm where a Windows frontend is concerned. My patches only add Toeplitz hashing into xen-netback according to the specification in xen's netif.h; the algorithm is not exposed for use by any other part of the kernel.
If it would help I can add a module parameter to xen-netback to control advertising the option of the hash to frontends so that it can be globally disabled if it is deployed on host where there are no Windows guests.

  Paul
