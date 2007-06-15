From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Xen-devel] [PATCH 0/4] [Net] Support accelerated network plugin modules
Date: Fri, 15 Jun 2007 14:21:01 +0200
Message-ID: <200706151421.01608.mb@bu3sch.de>
References: <C29842A2.9328%Keir.Fraser@cl.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kieran Mansley <kmansley@solarflare.com>,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:56434
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492AbXFOMVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 08:21:10 -0400
In-Reply-To: <C29842A2.9328%Keir.Fraser@cl.cam.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 15 June 2007 14:20:34 Keir Fraser wrote:
> 
> On 15/6/07 13:11, "Michael Buesch" <mb@bu3sch.de> wrote:
> 
> >> No use of the following please:
> >> If (foo) return 1; else return 0;
> >> Is clearer as:
> >> Return foo;
> > 
> > But it's not the same.
> > return !!foo;
> > would be the same. And yes, it does matter:
> 
> True in general, but not the cases I've seen in this patchset, where 'foo'
> is a predicate.

Ok, if foo is a variable containing an error code, it's
better to return that error code. I assumed that foo is a
variable containing some value (counter or something).

-- 
Greetings Michael.
