From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [E1000-devel] REGRESSION: panic on e1000 driver
Date: Thu, 31 May 2007 15:10:38 -0700
Message-ID: <465F47DE.6000606@intel.com>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net> <20070531010814.GA30709@gondor.apana.org.au> <1180624569.23536.7.camel@athlon> <465EE86C.6080301@intel.com> <20070531214812.GA9309@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Doug Chapman <doug.chapman@hp.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11146 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757947AbXEaWKr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 18:10:47 -0400
In-Reply-To: <20070531214812.GA9309@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, May 31, 2007 at 08:23:24AM -0700, Kok, Auke wrote:
>>> e1000: 0000:01:02.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:15:60:04:d7:f8
>>> e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
>>> e1000: 0000:01:02.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:15:60:04:d7:f9
>>> e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
>>> e1000: 0000:15:02.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:9e:b7:c4
>>> e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
>>> e1000: 0000:15:02.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:9e:b7:c5
>>> e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
>>> e1000: Unexpected interrupt icr=0x4
>> that's indeed the link status change we fire manually to trigger the 
>> watchdog run:
>>
>> #define E1000_ICR_LSC           0x00000004 /* Link Status Change */
> 
> This still makes no sense.  The only triggers I can find for this occur
> after e1000_irq_enable.  So unless we've got a problem with memory
> barriers we shouldn't get the above printk.
> 
> Is there another trigger that happens earlier?

none that I know....

Auke
