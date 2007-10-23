From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] Add eeprom_bad_csum_allow module option to e1000.
Date: Tue, 23 Oct 2007 16:19:25 -0700
Message-ID: <471E817D.5030500@intel.com>
References: <471E2AD0.1000500@intel.com>	<471E5C21.8030908@garzik.org>	<20071023212026.GF7793@redhat.com> <20071023.145339.55504234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, jeff@garzik.org, ajax@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32376 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752842AbXJWXTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 19:19:44 -0400
In-Reply-To: <20071023.145339.55504234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Dave Jones <davej@redhat.com>
> Date: Tue, 23 Oct 2007 17:20:26 -0400
> 
>> Indeed. This is a common enough problem that not including it causes
>> more pain than its worth.  I have two affected boxes myself that I
>> actually thought the hardware was dead before I tried ajax's patch.
>>
>> People aren't going to report this as a bug. They aren't going to
>> try out patches, they're going to do what I did and stick another
>> network card in the box and go on with life.
>>
>> Our users deserve better than this.
> 
> Seconded.  The resistence to this patch is just flat-out rediculious,
> just like it was in the e100 case.
> 
> And I think all of this "e1000 is different!" talk is merely a
> scarecrow for the fact that Intel simply doesn't want this patch
> merged for some other reason.

no, e1000 eeproms contain many timing information and bits crucial to getting the
adapter working in the first place. All of these are documented in our PUBLICALLY
available SDM which is downloadable from our e1000.sf.net website. (e.g. 8254x
sdm, section 5.6, page 98+). For pci-e silicon this gets much more complex.

we haven't even heard from the user what hardware he has nor gotten an eeprom dump
from him.

I'm not hiding anything and you're deliberately creating a negative atmosphere here.

The people who do have eeprom checksum issues have come to us in the past. The
fact that you didn't see them means that they *properly* made it to us.

As a matter of fact I am still working on a permanent solution for bad eeprom
checksums on lenovo T60 laptops. Should I just drop that issue and leave the real
problem unsolved?

This patch only affirms *YOUR* point of view, not that of many customers who have
come to us and received help with many issues. You're completely ignoring that and
that is unfair.

If we want this patch in the kernel in some form that actually shows in a decent
way what a user *should* do and more importantly should *know*, then maybe we can
talk about that.

The patch in question does not add any extra information nor does it do some
sanity checking on the eeprom values or turn off any of the problematic features
that we really should disable. We even have code that allows some of the hardware
to run without a properly setup eeprom in a few hardware cases. And we definately
should print out a lot more warnings to the user that running with garbage eeprom
data is _not_ a good idea.


Auke


