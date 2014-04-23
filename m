From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] mrf24j40: seperate mrf24j40 h/w init and add checkings
Date: Wed, 23 Apr 2014 16:00:09 +0200
Message-ID: <20140423140007.GA24286@omega>
References: <1398258716-18319-1-git-send-email-varkab@cdac.in>
 <5357C565.8080009@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Varka Bhadram <varkabhadram@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: Alan Ott <alan@signal11.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:46133 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbaDWOAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 10:00:17 -0400
Received: by mail-ee0-f41.google.com with SMTP id t10so842498eei.28
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 07:00:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5357C565.8080009@signal11.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alan,

On Wed, Apr 23, 2014 at 09:51:33AM -0400, Alan Ott wrote:
> On 04/23/2014 09:11 AM, Varka Bhadram wrote:
> >I followed the process that you mailed earlier, thnks for that.
> >
> >I am expecting the mail from Alan about the changes.
> 
> Hi Varka,
> 
> Is there a specific problem you're seeing? Typically in the kernel we expect
> the SPI controller to succeed for a couple reasons:
> 1. It's part of the basic, core functionality of a system. Checking for
> errors on SPI transfers is analogous to making sure RAM you wrote actually
> got written.
> 2. Most of the time an SPI failure is not something we can detect anyway.
> (disconnect one of the lines and see what you get).
> 3. The code to check for it just adds a lot of bloat without much measurable
> benefit.
> 
> I've read the above in the comments in other drivers, but I can't remember
> exactly where right now. There are plenty of examples in the kernel of SPI
> being done this way, as it seems to be accepted practice in the kernel.
> 
> If there is a specific issue that you're seeing, then let's talk about it,
> otherwise I'm going to NAK this change.
> 

if somebody hasn't a right spi configuration the probe function should
fail. Assumed that spi_sync will return a errno then.

- Alex
