From: jamal <hadi@cyberus.ca>
Subject: Re: FSCKED clock sources WAS(Re: [WIP][PATCHES] Network xmit
	batching
Date: Mon, 25 Jun 2007 13:16:44 -0400
Message-ID: <1182791804.5184.57.camel@localhost>
References: <20070619140038.GA13629@2ka.mipt.ru>
	 <1182270529.4968.73.camel@localhost>
	 <18040.5105.715624.286924@robur.slu.se>
	 <20070619.152801.99185860.davem@davemloft.net>
	 <1182441257.5017.48.camel@localhost> <1182442099.5017.51.camel@localhost>
	 <20070621165546.GH15814@kvack.org> <1182790794.5184.41.camel@localhost>
	 <20070625170807.GH971@kvack.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Robert.Olsson@data.slu.se,
	johnpol@2ka.mipt.ru, krkumar2@in.ibm.com, gaagaan@gmail.com,
	netdev@vger.kernel.org, rick.jones2@hp.com, sri@us.ibm.com
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:25177 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbXFYRQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 13:16:48 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1518015wxc
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 10:16:47 -0700 (PDT)
In-Reply-To: <20070625170807.GH971@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-25-06 at 13:08 -0400, Benjamin LaHaise wrote:

> CPUID:
> 
> vendor_id       : GenuineIntel
> cpu family      : 15
> model           : 4
> model name      : Intel(R) Xeon(TM) CPU 2.80GHz
> 
> shows that it is a P4 Xeon, which sucks compared to:
> 
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 15
> model name      : Genuine Intel(R) CPU                  @ 2.66GHz
> 
> which is a Core 2 based Xeon. 

Ok. Should the model name at least reflect one being a Xeon P4 and other
as core2 Xeon? ;->
 
>  The tuning required by the P4 is quite 
> different than the Core 2, and it generally performs more poorly due to 
> the length of the pipeline and the expense of pipeline flushes.

I would be very interested to see some numbers on a proper Core2 based
Xeon (unfortunately cant afford one). You have the hardware, what says
you? ;->
AFAIT, the main reason Opterons has the numbers it does is due to 
the integrated on chip MC. I dont see Intel any time soon getting rid of
that (for economical reasons more than technical).
In any case i see batching as actually being a lot more cache friendly
too.

cheers,
jamal 

