From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v6 15/16] cipso: Add support for native local labeling and fixup mapping names
Date: Wed, 1 Oct 2008 22:13:26 -0400
Message-ID: <200810012213.26916.paul.moore@hp.com>
References: <20080916124722.17132.38741.stgit@flek.lan> <200810011305.04872.paul.moore@hp.com> <alpine.LRH.1.10.0810020810570.12028@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:26684 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbYJBCNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 22:13:30 -0400
In-Reply-To: <alpine.LRH.1.10.0810020810570.12028@tundra.namei.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 01 October 2008 6:12:16 pm James Morris wrote:
> On Wed, 1 Oct 2008, Paul Moore wrote:
> > > ... and why specify zero filling?  (Setting and testing that
> > > would be wasted cycles, if you enforced it).
> >
> > Better alignment within the IP option field, the goal being to try
> > and get the secid aligned on a 32bit boundary.  However, it just
> > occurred to me that by adding the two octets of padding I've
> > actually pushed it out of alignment (I forgot about the obligatory
> > IP option type and length octets).
>
> I mean, why specify zero-filled rather than simply "unused" ?

Gotcha.  Yes, "unused" or "reserved" would be much better but it is 
kinda moot right now anyway since the Right Thing is to just remove the 
padding entirely.

> > Man I hate IPv4 options, what a parsing nightmare ...
>
> It was all fixed with IPv6, right? :-)

That is what the brochure says :)

-- 
paul moore
linux @ hp
