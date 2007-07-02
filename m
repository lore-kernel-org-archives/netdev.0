From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [2.6 patch] the overdue eepro100 removal
Date: Mon, 02 Jul 2007 15:02:45 -0400
Message-ID: <46894BD5.9080609@tmr.com>
References: <20070701202139.GM10869@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, saw@saw.sw.com.sg
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tmr.com ([64.65.253.246]:48433 "EHLO gaimboi.tmr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023AbXGBTBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 15:01:32 -0400
In-Reply-To: <20070701202139.GM10869@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch contains the overdue removal of the eepro100 driver.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
The hardware supported by this driver is still in use, thanks. It's 
probably easier to leave the eepro100 driver in than find anyone who 
wants to investigate why the other driver (e100? from memory) doesn't 
work with some cards. As I recall this was suggested over a year ago and 
it was decided to leave it in, all of the reasons for doing so still 
seem valid. There really doesn't seem to be a benefit, it's not like 
people are working night and day to support new cards for this chip.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
