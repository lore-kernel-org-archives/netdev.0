From: Andi Kleen <ak@suse.de>
Subject: Re: 2.6.18-mm2 boot failure on x86-64
Date: Thu, 5 Oct 2006 22:50:55 +0200
Message-ID: <200610052250.55146.ak@suse.de>
References: <20060928014623.ccc9b885.akpm@osdl.org> <200610052105.00359.ak@suse.de> <1160080954.29690.44.camel@flooterbu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Badari Pulavarty <pbadari@us.ibm.com>,
	Martin Bligh <mbligh@mbligh.org>, vgoyal@in.ibm.com,
	Andrew Morton <akpm@osdl.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	kmannth@us.ibm.com, Andy Whitcroft <apw@shadowen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:32921 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932147AbWJEUvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 16:51:05 -0400
To: Steve Fox <drfickle@us.ibm.com>
In-Reply-To: <1160080954.29690.44.camel@flooterbu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 05 October 2006 22:42, Steve Fox wrote:
> On Thu, 2006-10-05 at 21:05 +0200, Andi Kleen wrote:
> 
> > Can you please try it again with this patch to narrow it down further?
> 
> Unfortunately this is as far as it got before it hung.

Boot with earlyprintk=serial,ttyS0,57600
(or change the panic in the checkfunction back to a printk) 

-Andi

