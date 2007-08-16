From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH] [DM9000] Add support for big-endian hosts
Date: Thu, 16 Aug 2007 10:10:56 +0200
Message-ID: <200708161010.57064.laurentp@cse-semaphore.com>
References: <200708141322.32473.laurentp@cse-semaphore.com> <20070814182558.GA12547@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Dooks <ben@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:17469 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751326AbXHPIK7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 04:10:59 -0400
In-Reply-To: <20070814182558.GA12547@fluff.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 August 2007 20:25, Ben Dooks wrote:
> On Tue, Aug 14, 2007 at 01:22:32PM +0200, Laurent Pinchart wrote:
> > This patch splits the receive status in 8bit wide fields and conver=
t the
> > packet length from little endian to CPU byte order.
>
> Which version of the the kernel was this against, it applies with
> fuzz to 2.6.23-rc3:
>
> $ patch -p1 < ~/dm9000-fix-endianness.patch
> patching file drivers/net/dm9000.c
> Hunk #1 succeeded at 894 (offset 15 lines).
> Hunk #2 succeeded at 936 (offset 15 lines).
> Hunk #3 succeeded at 948 (offset 15 lines).

That was against 2.6.22. Sorry. I'll post updated patches against 2.6.2=
3-rc3.

Best regards.

--=20
Laurent Pinchart
CSE Semaphore Belgium

Chauss=E9e de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75
