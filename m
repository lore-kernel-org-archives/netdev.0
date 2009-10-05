From: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Subject: RE: [net-next-2.6 PATCH 1/9] vxge: Modify __vxge_hw_device_is_privilaged() to not assume function-0 as privilaged function.
Date: Mon, 5 Oct 2009 06:07:25 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705C16191@nekter>
References: <Pine.GSO.4.10.10910050503530.2346-100000@guinness><20091005.022017.252887922.davem@davemloft.net><78C9135A3D2ECE4B8162EBDCE82CAD7705C1618F@nekter> <20091005.024837.62378837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:9398 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932494AbZJEKHr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 06:07:47 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20091005.024837.62378837.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, I will re-create and submit them again. 

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Monday, October 05, 2009 3:19 PM
To: Sreenivasa Honnur
Cc: netdev@vger.kernel.org; support
Subject: Re: [net-next-2.6 PATCH 1/9] vxge: Modify
__vxge_hw_device_is_privilaged() to not assume function-0 as privilaged
function.

From: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Date: Mon, 5 Oct 2009 05:40:18 -0400

> I could apply these patches with "patch -p1 patch_file" command.

davem@sunset:~/src/GIT/net-next-2.6$ git am --signoff x.mbox
Applying: vxge: Modify __vxge_hw_device_is_privilaged() to not assume
function-0 as privilaged function.
error: /drivers/net/vxge/vxge-config.c: does not exist in index
error: patch failed: drivers/net/vxge/vxge-config.c:461
error: drivers/net/vxge/vxge-config.c: patch does not apply
error: /drivers/net/vxge/vxge-version.h: does not exist in index Patch
failed at 0001 vxge: Modify __vxge_hw_device_is_privilaged() to not
assume function-0 as privilaged function.

GIT is more strict than patch in many ways (not just in respect to
paths).
