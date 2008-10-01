From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v6 01/16] selinux: Cleanup the NetLabel glue code
Date: Wed, 1 Oct 2008 12:34:36 -0400
Message-ID: <200810011234.37020.paul.moore@hp.com>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125554.17132.61538.stgit@flek.lan> <alpine.LRH.1.10.0810011135140.5277@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:48920 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbYJAQel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 12:34:41 -0400
In-Reply-To: <alpine.LRH.1.10.0810011135140.5277@tundra.namei.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 30 September 2008 9:35:46 pm James Morris wrote:
> On Tue, 16 Sep 2008, Paul Moore wrote:
> > We were doing a lot of extra work in selinux_netlbl_sock_graft()
> > what wasn't necessary so this patch removes that code.  It also
> > removes the redundant second argument to
> > selinux_netlbl_sock_setsid() which allows us to simplify a few
> > other functions.
> >
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
>
> Nice cleanup :-)
>
> Acked-by: James Morris <jmorris@namei.org>

Thanks, every once in a while I get lucky ;)

-- 
paul moore
linux @ hp
