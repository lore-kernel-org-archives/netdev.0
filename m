From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] FRV: do_gettimeofday() should no longer use tickadj
Date: Wed, 06 Sep 2006 10:27:33 +0100
Message-ID: <8430.1157534853@warthog.cambridge.redhat.com>
References: <1157507203.2222.11.camel@localhost>  <20060905132530.GD9173@stusta.de> <20060901015818.42767813.akpm@osdl.org> <6260.1157470557@warthog.cambridge.redhat.com>
Cc: David Howells <dhowells@redhat.com>, Adrian Bunk <bunk@stusta.de>,
	Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:16308 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750732AbWIFJ3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 05:29:11 -0400
In-Reply-To: <1157507203.2222.11.camel@localhost> 
To: john stultz <johnstul@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

john stultz <johnstul@us.ibm.com> wrote:

> From this patch it looks like the FRV arch could be trivially converted
> to GENERIC_TIME.
> 
> Would you consider the following, totally untested patch?

It certainly looks interesting.  I'll have to study the clocksource stuff -
some FRV CPUs have an effective TSC.

David
