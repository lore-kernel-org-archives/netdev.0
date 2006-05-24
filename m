From: jamal <hadi@cyberus.ca>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Wed, 24 May 2006 14:43:08 -0400
Message-ID: <1148496189.5325.33.camel@jzny2>
References: <44731733.7000204@ti-wmc.nl>
	 <20060523094324.11926fcc@localhost.localdomain>
	 <447349A6.50105@fastmail.fm>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:34694 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932470AbWEXSnK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 14:43:10 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FiyKB-0002d5-0E
	for netdev@vger.kernel.org; Wed, 24 May 2006 14:43:15 -0400
To: Simon Oosthoek <wmc_simon@fastmail.fm>
In-Reply-To: <447349A6.50105@fastmail.fm>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-23-05 at 19:43 +0200, Simon Oosthoek wrote:
> Stephen Hemminger wrote:
> > On Tue, 23 May 2006 16:07:47 +0200
> > Herman Elfrink <herman.elfrink@ti-wmc.nl> wrote:
> > 
> >>  
> >> FLAME stands for "Forwarding Layer for Meshing"
> >>
> > 
> > Didn't you just reinvent 802.1d bridging? and/or WDS?
> 
> I wouldn't say "reinvent", but the difference is small but significant. 
> FLAME could be seen as ad hoc WDS, I think. It doesn't need to know 
> about the other "base-stations", which I think WDS does.
> 

Essentially you are extending the broadcast domain i.e a bridge within
on top of a bridge. I would question the scalability of such a beast
in the presence of many nodes. Also take a look at some of the work
Radia Perlman (who invented bridging really) is up to these days.

cheers,
jamal



