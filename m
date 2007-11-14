From: "Kok, Auke" <sofar@foo-projects.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 10:27:02 -0800
Message-ID: <473B3DF6.100@foo-projects.org>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <200711131739.45820.vda.linux@googlemail.com> <20071114072715.GO4250@stusta.de> <200711140046.20391.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, Theodore Tso <tytso@mit.edu>,
	Benoit Boissinot <bboissin@gmail.com>, Mark Lord <liml@rtr.ca>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:58367 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751793AbXKNS1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 13:27:32 -0500
In-Reply-To: <200711140046.20391.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys Vlasenko wrote:
> On Wednesday 14 November 2007 00:27, Adrian Bunk wrote:
>> You missed the following in my email:
>> "we slowly scare them away due to the many bug reports without any
>>  reaction."
>>
>> The problem is that bug reports take time. If you go away from easy
>> things like compile errors then even things like describing what does
>> no longer work, ideally producing a scenario where you can reproduce it
>> and verifying whether it was present in previous kernels can easily take
>> many hours that are spent before the initial bug report.
>>
>> If the bug report then gets ignored we discourage the person who sent
>> the bug report to do any work related to the kernel again.
> 
> Cannot agree more. I am in a similar position right now.
> My patch to aic7xxx driver was ubmitted four times
> with not much reaction from scsi guys.
> 
> Finally they replied and asked to rediff it against their
> git tree. I did that and sent patches back. No reply since then.
> 
> And mind you, the patch is not trying to do anything
> complex, it mostly moves code around, removes 'inline',
> adds 'const'. What should I think about it?

this has nothing to do with the bugs on bugzilla.

you're trying to send a janitor patch. It should be logical that the response to
that is not heated or receiving a joyous reception :)

If you have a problem getting your cleanup patch to the driver maintainer, send it
to the subsystem maintainer instead, or even the janitors, or even Adrian Bunk who
will gladly push it to everyone. Or, even to Andrew Morton who will carry it in
-mm for a while and then harrasses the subsystem maintainer to merge it for you!

Cheers,

Auke
