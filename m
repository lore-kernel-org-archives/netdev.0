From: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Subject: RE: [net-next-2.6 PATCH 1/9] vxge: Modify __vxge_hw_device_is_privilaged() to not assume function-0 as privilaged function.
Date: Mon, 5 Oct 2009 05:43:30 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705C16190@nekter>
References: <Pine.GSO.4.10.10910050503530.2346-100000@guinness> <20091005.022017.252887922.davem@davemloft.net> <78C9135A3D2ECE4B8162EBDCE82CAD7705C1618F@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:9078 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758747AbZJEJoO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:44:14 -0400
Content-class: urn:content-classes:message
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7705C1618F@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I could apply these patches with "patch -p1 < patch_file" command.

i.e /usr/src/davem-net-2.6 # patch -p1 < patch_2-0-6-1


-----Original Message-----
From: Sreenivasa Honnur 
Sent: Monday, October 05, 2009 3:10 PM
To: David Miller
Cc: netdev@vger.kernel.org; support
Subject: RE: [net-next-2.6 PATCH 1/9] vxge: Modify
__vxge_hw_device_is_privilaged() to not assume function-0 as privilaged
function.

I could apply these patches with "patch -p1 patch_file" command.

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: Monday, October 05, 2009 2:50 PM
To: Sreenivasa Honnur
Cc: netdev@vger.kernel.org; support
Subject: Re: [net-next-2.6 PATCH 1/9] vxge: Modify
__vxge_hw_device_is_privilaged() to not assume function-0 as privilaged
function.

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Mon, 5 Oct 2009 05:06:06 -0400 (EDT)

> - vxge driver was assuming function-0 is always the privilaged
function. Now that
>   restriction has been removed any function can act as a privilaged
function.
> 
> - This patch modifies the __vxge_hw_device_is_privilaged routine to
not assume
>   function-0 as the privileged function.
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> ---
> diff -urpN orig//drivers/net/vxge/vxge-config.c
patch1//drivers/net/vxge/vxge-config.c
> --- orig//drivers/net/vxge/vxge-config.c	2009-09-03
22:39:48.000000000 -0700
> +++ patch1//drivers/net/vxge/vxge-config.c	2009-09-03
23:11:24.000000000 -0700

You can't have the double slash there in your paths, this gets
interpreted as "/drivers/net/vxge/vxge-config.c" by all the patch
applying tools.

Please "-p1" root your patches properly as described in
linux/Documentation/SubmittingPatches

You'll need to resubmit your entire patch set with this fixed up.

Thanks.

