From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCHSET 0/18] FRTO: fixes and small changes + SACK enhanced
 version
Date: Thu, 22 Feb 2007 14:25:32 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0702221305380.19465@kivilampi-30.cs.helsinki.fi>
References: <11717439662097-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070222.001519.66175915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44028 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945985AbXBVMZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 07:25:34 -0500
In-Reply-To: <20070222.001519.66175915.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Feb 2007, David Miller wrote:

> If you have any further bug fixes or enhancements to FRTO we
> can put it there too.

I tried the rate-halving approach in spurious RTO response and it looks 
really nice indeed. I'll try to also run couple of tests with the 
undo_cwr(,1) response too in near future to ensure that it doesn't 
cause immediate breakage with something.

Before preparing the submittable spurious RTO responses patch, I would 
like to know what is the preferred style for the response selector code 
(I'm controlling the response through frto_response sysctl)? switch? array 
of function pointers? If array, where to place it (considering the need 
for forward declarations and mixing of code and data in some approaches)?


-- 
 i.
