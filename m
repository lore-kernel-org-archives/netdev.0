From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 0/3] remove irq_sem cruft from e1000 and derivatives
Date: Mon, 19 Feb 2007 17:06:26 -0800
Message-ID: <45DA4992.2070103@intel.com>
References: <20070220.Bq5.44322700@egw.corp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, jacliburn@bellsouth.net, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3584 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965874AbXBTBG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 20:06:28 -0500
In-Reply-To: <20070220.Bq5.44322700@egw.corp.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook wrote:
> Hey folks --
> 
>      While digging through the atl1 source, I was troubled by the code using
> irq_sem.  I did some digging and found the same code in e1000 and ixgb.  I'm
> not entirely sure what it was originally intended to do, but it doesn't seem
> to be doing anything useful now, except possibly locking interrupts off if
> NAPI is flipped on and off enough times to cause an integer overflow.
> 
>      The following patches completely remove irq_sem from each of the drivers.
>  This has been tested successfully on atl1 and e1000.  If someone would like
> to send me ixgb hardware I'd be glad to test that, otherwise you'll have to
> test it yourself. :)
> 
>      -- Chris


I'm not yet seeing patches 1/3 appear, but I'll certainly take a look at them 
and have them tested in our labs once they appear for e1000 and ixgb.

Cheers,

Auke
