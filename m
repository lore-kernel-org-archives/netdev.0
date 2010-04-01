From: "Ramkrishna Vepa" <Ramkrishna.Vepa@exar.com>
Subject: RE: [net-next-2.6 PATCH 3/8] vxge: Align the memory only if it is misaligned.
Date: Thu, 1 Apr 2010 18:05:23 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77065BC991@nekter>
References: <Pine.GSO.4.10.11003290409080.4435-100000@guinness> <20100329.165945.157920838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:20553 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869Ab0DAWFZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 18:05:25 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100329.165945.157920838.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If you want to allocate 4K chunks and make sure they are at least 128
> byte aligned, you can allocated pages (which are always PAGE_SIZE
> aligned) and chop them up into the appropriate block size as needed.
> 
> This is exactly how drivers/net/niu.c handles this situation.
> 
> See drivers/net/niu.c:niu_rbr_add_page()
Thanks Dave! There's quite a bit of change required in the driver for
this. We'll submit the current set of patches we are working on and then
look into submitting this change.

Ram
