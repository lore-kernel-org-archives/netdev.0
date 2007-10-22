From: Eric Sandeen <sandeen@redhat.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Mon, 22 Oct 2007 09:59:53 -0500
Message-ID: <471CBAE9.6010406@redhat.com>
References: <7DCDA0F058071B49AED9D3D7886C41BE0966AEDB@muon.jnpr.net> <47179F1F.3030202@intel.com> <20071022010440.GA11165@redhat.com> <7DCDA0F058071B49AED9D3D7886C41BE0A43B10E@muon.jnpr.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, esandeen@redhat.com
To: David Mack <dmack@juniper.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35476 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859AbXJVPAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 11:00:09 -0400
In-Reply-To: <7DCDA0F058071B49AED9D3D7886C41BE0A43B10E@muon.jnpr.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Mack wrote:
> Then I got very, very lucky, since I have successfully rebooted
> 2.6.23.1-23.fc8 four times (zero panics) and this is the first time a
> 2.6.23 kernel has not panicked on me in months.
> 
> This does not fill me with confidence in the theory that the panics I've
> been seeing are due to a race condition.

I'll agree with the testing results, at least.  I booted successfully
*60* times with 2.6.23.1-23.fc8, booting the stock F8test3 kernel would
oops every 5 or 6 boots.

It may well be a race, but if so something is apparently opening/closing
the window on us! :)

-Eric
