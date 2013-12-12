From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] ipv6 addrconf:fix preferred lifetime state-changing behavior while valid_lft is infinity
Date: Thu, 12 Dec 2013 02:03:48 +0100
Message-ID: <20131212010348.GD4675@order.stressinduktion.org>
References: <4AE7B88EC8BA74469869BB7EEB7D66671BF656D2@g01jpexmbyt23> <20131209234704.GF7396@order.stressinduktion.org> <4AE7B88EC8BA74469869BB7EEB7D66671BF674D0@g01jpexmbyt23>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Asano, Yasushi" <yasushi.asano@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49617 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000Ab3LLBDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 20:03:49 -0500
Content-Disposition: inline
In-Reply-To: <4AE7B88EC8BA74469869BB7EEB7D66671BF674D0@g01jpexmbyt23>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 12:58:10AM +0000, Asano, Yasushi wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org
> > [mailto:netdev-owner@vger.kernel.org] On Behalf Of Hannes Frederic Sowa
> > Sent: Tuesday, December 10, 2013 8:47 AM
> > To: Asano, Yasushi
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [PATCH 1/1] ipv6 addrconf:fix preferred lifetime
> > state-changing behavior while valid_lft is infinity
> > Importance: High
> > 
> > On Mon, Dec 09, 2013 at 05:54:37AM +0000, Asano, Yasushi wrote:
> > > from: Yasushi Asano  <yasushi.asano@jp.fujitsu.com>
> > >
> > > There is a problem when setting the lifetime of an IPv6 address.
> > > When I set preferred_lft to a value not zero or infinity, while valid_lft
> > is infinity(0xffffffff)
> > > preferred lifetime is set to forever and does not update.
> > > Therefore preferred lifetime never becomes deprecated.
> > >
> > > I think valid lifetime and preferred lifetime should be set independently,
> > > even if valid lifetime is infinity, preferred lifetime must expire
> > correctly (meaning it must eventually become deprecated)
> > >
> > > I made a patch for 3.12 stable to solve the problem.
> > 
> > This indeed could be improved. Thanks for the patch. But you should base
> > it on net-next so it can be applied and please clean up the warnings
> > and errors if you run the patch through ./scripts/checkpatch --strict.
> > 
> > Thank you,
> > 
> >   Hannes
> > 
> I made a patch based on net-next and emailed ML using git send-email last night.
> 
> Subject: [PATCH 1/1] ipv6 addrconf:fix preferred lifetime state-changing behavior while valid_lft is infinity
> Date: Wed, 11 Dec 2013 19:57:32 +0900
> Message-ID: <1386759452-22159-1-git-send-email-yasushi.asano@jp.fujitsu.com>
> X-Mailer: git-send-email 1.7.12.4
> 
> Thank you for your time and assistance regarding this matter.
> Yasushi

Huch? I have not seen anything nor has patchworks:
http://patchwork.ozlabs.org/project/netdev/list/

Greetings,

  Hannes
