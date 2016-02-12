From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v1 0/8] xen-netback: support toeplitz hashing
Date: Fri, 12 Feb 2016 11:07:50 +0000
Message-ID: <47dcce9fc54b42f591284cd8ea72ddba@AMSPEX02CL03.citrite.net>
References: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
 <20160212.055408.1901988218281607996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:53357 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752352AbcBLLHx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 06:07:53 -0500
In-Reply-To: <20160212.055408.1901988218281607996.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: 12 February 2016 10:54
> To: Paul Durrant
> Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org
> Subject: Re: [PATCH net-next v1 0/8] xen-netback: support toeplitz hashing
> 
> From: Paul Durrant <paul.durrant@citrix.com>
> Date: Fri, 12 Feb 2016 10:13:17 +0000
> 
> > This patch series adds support for frontend-configurable toeplitz hashing
> > in xen-netback (on the guest receive side). This support has been testing
> > against a Windows frontend and has proven to be sufficient to pass the
> > Microsoft HCK NDIS RSS tests.
> 
> We want less Toeplitz users, not more of them.  It is a more unsuitable
> hash than jhash2.
> 
> I'm not applying these patches, sorry.

Windows *requires* use of Teoplitz so your position completely rules out being able to support receive side scaling in Windows PV frontends on Linux kernel backends, not only for Xen but for any other hypervisor, which I think is totally unreasonable.

  Paul
