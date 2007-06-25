From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: FSCKED clock sources WAS(Re: [WIP][PATCHES] Network xmit batching
Date: Mon, 25 Jun 2007 13:08:07 -0400
Message-ID: <20070625170807.GH971@kvack.org>
References: <20070619140038.GA13629@2ka.mipt.ru> <1182270529.4968.73.camel@localhost> <18040.5105.715624.286924@robur.slu.se> <20070619.152801.99185860.davem@davemloft.net> <1182441257.5017.48.camel@localhost> <1182442099.5017.51.camel@localhost> <20070621165546.GH15814@kvack.org> <1182790794.5184.41.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Robert.Olsson@data.slu.se,
	johnpol@2ka.mipt.ru, krkumar2@in.ibm.com, gaagaan@gmail.com,
	netdev@vger.kernel.org, rick.jones2@hp.com, sri@us.ibm.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:33413 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750870AbXFYRIT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2007 13:08:19 -0400
Content-Disposition: inline
In-Reply-To: <1182790794.5184.41.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 25, 2007 at 12:59:54PM -0400, jamal wrote:
> On Thu, 2007-21-06 at 12:55 -0400, Benjamin LaHaise wrote:
> 
> > You should qualify that as 'Old P4 Xeon', as the Core 2 Xeons are leagues 
> > better.
> 
> The Xeon hardware is not that old - about a year or so (and so is the
> opteron). 
> BTW, how could you tell this was old Xeon?

CPUID:

vendor_id       : GenuineIntel
cpu family      : 15
model           : 4
model name      : Intel(R) Xeon(TM) CPU 2.80GHz

shows that it is a P4 Xeon, which sucks compared to:

vendor_id       : GenuineIntel
cpu family      : 6
model           : 15
model name      : Genuine Intel(R) CPU                  @ 2.66GHz

which is a Core 2 based Xeon.  The tuning required by the P4 is quite 
different than the Core 2, and it generally performs more poorly due to 
the length of the pipeline and the expense of pipeline flushes.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
