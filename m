From: Eric Sandeen <sandeen@redhat.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Tue, 16 Oct 2007 10:47:07 -0500
Message-ID: <4714DCFB.8020408@redhat.com>
References: <E1IgWqn-0000iU-00@gondolin.me.apana.org.au> <4714CBAB.4090601@redhat.com> <20071016143505.GA12640@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Mack <dmack@juniper.net>, davej@redhat.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
To: Herbert Xu <herbert.xu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49400 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932582AbXJPPrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 11:47:24 -0400
In-Reply-To: <20071016143505.GA12640@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Oct 16, 2007 at 09:33:15AM -0500, Eric Sandeen wrote:
>> Hm... running 2.6.23-6.fc8, I've been through 30+ reboot cycles without
>> a problem.  Before, I'd oops every 5 or so times I booted...
>>
>> I now have another NIC in the box, disabled; I don't think that should
>> be affecting anything?
> 
> Well the original problem was caused by spurious interrupts on
> the IRQ line where your e100 is so it could well be sporadic.

Hah, well, I took the other NIC out and it didn't survive more than a
couple reboots on that kernel.

Now that I know I can still hit it, I'll do any testing that's needed.

Thanks,

-Eric
