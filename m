From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: ANNOUNCE: igb: Intel 82575 Gigabit Ethernet driver (PCI-Express)
Date: Thu, 19 Jul 2007 16:52:02 -0700
Message-ID: <469FF922.2090900@intel.com>
References: <46980ADA.5050104@intel.com> <469ED3D7.6040905@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8474 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760907AbXGSXwf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 19:52:35 -0400
In-Reply-To: <469ED3D7.6040905@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>>      http://foo-projects.org/~sofar/igb.patch       [558K]
>>      http://foo-projects.org/~sofar/igb.patch.bz2   [98K]
> 
> Just took a look at this.
> 
> This has the same problem as in the other thread -- huge internal API -- 
> except this time, the problem is emphasized by the fact that the 
> majority of the API hooks only have a single user, making each hook and 
> API entry point demonstrably useless overhead.
> 
> Please remove the useless internal API and resubmit.

Why don't you accept it now and allow us the time to work on this in the coming 
period? The driver works, performs better than all 8257x hardware and uses less 
CPU utilization. That must be good for everyone. Keeping it outside of the linux 
tree is just going to postpone testing the non-internal API parts.

> PLEASE take a look at how bnx2 and tg3 are structured.

They don't use PHYlib. Nobody is perfect...

We can and we should be able to _not_ agree on certain things and live together 
just fine. While I agree that some designs are better, the current internal API 
design has worked really good for us and allowed us to develop this driver and 
ixgbe in much faster rate than ever before. It was most useful in silicon 
validation and extremely flexible for us. At one point, the 82575 silicon was 
even supporter by the e1000 driver, because this internal API made it so easy to 
add new hardware support. For obvious reasons (differences in hw) we decided to 
split this driver off.

It served a good purpose. We can improve it, and I sure want to do that, but I 
think it's better to improve something *upstream*, then going back working at 
things offline without having any certainty that you will accept it after I get 
back, since you might just reject it on another argument, etc. It will take 
quite some effort and convincing to make this happen, and it would help a lot if 
we can work with/in the community on that, instead of off-line.

That will also give the non-internal API parts the better testing.


Auke
