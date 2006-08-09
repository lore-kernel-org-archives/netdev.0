From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH] pcnet32: break in 2.6.18-rc1 identified (corrected)
Date: Wed, 9 Aug 2006 08:35:01 -0700
Message-ID: <20060809153501.GA30459@us.ibm.com>
References: <20060804162628.GA7229@us.ibm.com> <44D95E1E.9010403@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: murrayma@citi.umich.edu, netdev@vger.kernel.org, strel@ioc.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:60879 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750730AbWHIPeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 11:34:31 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k79FYUNi029488
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 9 Aug 2006 11:34:30 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k79FYUUs289316
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 9 Aug 2006 11:34:30 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k79FYTIZ011289
	for <netdev@vger.kernel.org>; Wed, 9 Aug 2006 11:34:30 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <44D95E1E.9010403@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 12:01:34AM -0400, Jeff Garzik wrote:
> Don Fry wrote:
> >I noticed this morning that I had the polarity wrong in my patch
> >yesterday for older chips in the pcnet32_suspend routine.  Here is the
> >correct patch to test.
> >
> >>A change I made for 2.6.17 and another for 2.6.18 do not work on older
> >>pcnet32 chips which I do not have access to.  Please test this patch if
> >>you have access to a 79C970, 79C974, or 79C965 (VLB) version of the
> >>pcnet32 and let me know if it solves any problems.  I have tested with a
> >>79C970A, 79C971, 79C972, 79C973, 79C975, 79C976, and 79C978 and the
> >>changes work as expected.
> 
> Did testing succeed?
> 

I have not heard anything about testing results yet.  I have tested
successfully with the hardware I have, but there are at least three
variants of the chip that I have not been able to find.  "It should
work" are the famous last words of most programmers ;-(.  I received an
email from Martin on Saturday that he had been traveling and would get
back to me.  I believe that the patch will resolve the issue with older
cards.  The patch is no worse than what is in 2.6.18-rc4 today, but
removing the offending patch is also an option.

The patch also addresses an issue raised by Yuri Strelenko that the
changes in 2.6.17 caused his 79C970 to stop working.  I have sent him a
patch as well, but have heard nothing from him.  Those changes I am much
more positive about, but I would like confirmation that I have not
broken something else.

When I have some positive results, I will add the signed-off-by line and
resubmit the patch or ask for the old patch to be removed.  When does
the patch need to be submitted in order to be included in 2.6.18?

> signed-off-by?
> 
> 	Jeff
-- 
Don Fry
brazilnut@us.ibm.com
