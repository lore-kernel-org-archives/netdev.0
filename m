From: =?ISO-8859-1?Q?Anders_Grafstr=F6m?= <grfstrm@users.sourceforge.net>
Subject: Re: [PATCH] Fix e100 on systems that have cache incoherent DMA
Date: Wed, 02 Jul 2008 19:36:16 +0200
Message-ID: <486BBC90.8030708@users.sourceforge.net>
References: <20071108181741.8648.61629.stgit@localhost.localdomain>	<474DBDA6.50705@roinet.com>	<474DBFCE.8010101@intel.com>	<474DC0F3.8070604@garzik.org>	<474DC68D.9020003@roinet.com>	<485959DC.80902@users.sourceforge.net>	<48595F16.5000905@roinet.com>	<485A5349.6070601@users.sourceforge.net>	<20080701012631.c3d1d262.akpm@linux-foundation.org>	<4869FDBB.80501@garzik.org> <20080701110759.4df83d71.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	=?ISO-8859-1?Q?Anders_Grafstr=F6m?= <grfstrm@users.sourceforge.net>,
	David Acker <dacker@roinet.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, miltonm@bga.com,
	e1000-devel@lists.sourceforge.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([212.247.11.2]:29072 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751016AbYGBRgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 13:36:24 -0400
In-Reply-To: <20080701110759.4df83d71.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Tue, 01 Jul 2008 05:49:47 -0400 Jeff Garzik <jeff@garzik.org> wrote:
> 
>> Andrew Morton wrote:
>>> On Thu, 19 Jun 2008 14:38:33 +0200 Anders Grafstr__m <grfstrm@users.sourceforge.net> wrote:
>>>
>>>> David Acker wrote:
>>>>> May I ask what actual board you are using and how the e100 is connected 
>>>>> to it?  I plan to test with miniPCI based e100 cards.  Also, can you say 
>>>>> more about it being broke?  Does it crash immediately, fail to move any 
>>>>> data, move some data and stop, etc. ?
>>>> It's a custom board based on the IXDP425 reference design.
>>>> IXP420 with 82551ER integrated on the same board.
>>>> Both RX and TX appears to stop shortly after the driver has been initialized.
>>>> It never recovers after the "exec cuc_dump_reset failed" messages start to show.
>>> So..  where are we with this?
>> It's in net-2.6, davem's 2.6.26-rc queue.
>>
> 
> ah, thanks.  Is it needed in 2.6.25.x?

I think so.

