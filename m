From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Tue, 21 Oct 2008 09:29:02 +0200
Message-ID: <1224574142.17450.321.camel@ecld0pohly>
References: <1224253423.17450.211.camel@ecld0pohly>
	 <48F96DD6.5060904@cosmosbay.com> <48F99286.9050706@hartkopp.net>
	 <48F9A43A.7070801@cosmosbay.com>  <48F9B610.2090504@hartkopp.net>
	 <1224488114.17450.224.camel@ecld0pohly>  <48FCC777.4020506@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10828 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207AbYJUHbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 03:31:14 -0400
In-Reply-To: <48FCC777.4020506@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-20 at 11:01 -0700, Oliver Hartkopp wrote:
> Patrick Ohly wrote:
> > The last time this topic was discussed the initial proposal also was to
> > add another time stamp, pretty much for the same reasons. This approach
> > was discarded because enlarging a common structure like skb for rather
> > obscure ("Objection, your honor!" - "Rejected.") use cases is not
> > acceptable.
> 
> I don't want to raise dust again

Please, keep raising that dust ;-) I'd very much prefer to have an
another field myself, but I also want to get the patch into the upstream
kernel. The more people argue in favor of adding it, the more likely
that gets.

In the meantime I'll proceed with an implementation based on bit
mangling. The latest iteration of the user space APIs hide this
implementation detail, so it'll be easy to switch from bit mangling to a
separate field.

> >  A config option doesn't help much either because to be
> > useful for distribution users, it would have to be on by default.
> >
> 
> Hm - i tried to follow your points in the linked PDF
> (http://www.linuxclustersinstitute.org/conferences/archive/2008/PDF/Ohly_92221.pdf)
> - and from my perspective having a kernel config option looks like an
> appropriate solution here. Either some CAN controllers or HPC clusters
> that would benefit from HW timestamps are IMHO no 'standard use-cases'
> that use 'standard kernels' provided by a 'standard distributor', right?

My estimation is that there are a lot more HPC clusters which use
standard "Enterprise Linux" distributions with vendor support and/or
cannot/do not want to use a self-compiled kernel. My goal therefore is
to have the support for HW time stamps enabled in the default kernel
configuration.

Perhaps the "use separate field" implementation of that support could be
selected via an option for those who really need it.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

