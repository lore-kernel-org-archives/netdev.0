From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sb1250-mac.c: De-typedef, de-volatile, de-etc...
Date: Thu, 20 Sep 2007 00:10:54 -0400
Message-ID: <46F1F2CE.7020300@pobox.com>
References: <Pine.LNX.4.64N.0709101310030.25038@blysk.ds.pg.gda.pl> <46E8B56E.7060705@pobox.com> <Pine.LNX.4.64N.0709131506040.31069@blysk.ds.pg.gda.pl> <20070913151452.GB29665@linux-mips.org> <46E95C7F.1050302@pobox.com> <Pine.LNX.4.64N.0709141135290.1926@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55614 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806AbXITELB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 00:11:01 -0400
In-Reply-To: <Pine.LNX.4.64N.0709141135290.1926@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej W. Rozycki wrote:
>  Remove typedefs, volatiles and convert kmalloc()/memset() pairs to
> kcalloc().  Also reformat the surrounding clutter.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
> On Thu, 13 Sep 2007, Jeff Garzik wrote:
> 
>> Net driver patches should apply on top of netdev-2.6.git#upstream, which is
>> where changes to net drivers are queued for the next release.
> 
>  I can see Andrew has done some changes to the patch and applied it 
> anyway, but here's a version I generated against your tree.  Please feel 
> free to choose either.
> 
>  You may be pleased (or less so) to hear that the version of sb1250-mac.c 
> in your tree does not even build (because of 
> 42d53d6be113f974d8152979c88e1061b953bd12) and the patch below does not 
> address it.  I ran out of time in the evening, but I will send you a fix 
> shortly.  To be honest I think even with bulk changes it may be worth 
> checking whether they do not break stuff. ;-)

hrm.  I cannot get this to apply on top of linux-2.6.git, 
netdev-2.6.git#upstream (prior to net-2.6.24 rebase) or 
netdev-2.6.git#upstream (after net-2.6.24 rebase)

ACK the changes

