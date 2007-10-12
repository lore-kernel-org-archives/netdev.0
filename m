From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Fri, 12 Oct 2007 10:04:31 -0700
Message-ID: <470FA91F.1080302@intel.com>
References: <46FAA083.9020604@intel.com> <E1IanKN-0003ju-00@gondolin.me.apana.org.au> <20071011003638.GA27174@redhat.com> <20071011012520.GA13160@gondor.apana.org.au> <470E4AFA.60507@intel.com> <20071011172551.GA21339@redhat.com> <7DCDA0F058071B49AED9D3D7886C41BE0A43AD1D@muon.jnpr.net> <20071012153550.GB28708@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Mack <dmack@juniper.net>, Dave Jones <davej@redhat.com>,
	netdev@vger.kernel.org, esandeen@redhat.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53684 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932942AbXJLRIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 13:08:18 -0400
In-Reply-To: <20071012153550.GB28708@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Oct 12, 2007 at 07:54:33AM -0700, David Mack wrote:
>> Still no joy here. See attached capture. What's really weird is that it
>> shows *two* kernel panics, one in  e100_poll and one in _list_add.
> 
> Yes that's the symptom one would expect from that bug.  We really
> need to apply the same fix that was done for e1000.

I feared that. its not the same as that commit that floated around in this thread
and involves some reorganization in the init/probe code, so it's a bit more
involved than just a few lines. I'll need a little bit of time to generate this fix.

Auke
