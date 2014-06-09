From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 1/3] iproute2: arpd: use ll_addr_a2n and
 ll_addr_n2a
Date: Mon, 9 Jun 2014 12:47:22 -0700
Message-ID: <20140609124722.33295eb5@nehalam.linuxnetplumber.net>
References: <1400159422-11797-1-git-send-email-jiri@resnulli.us>
	<1400159422-11797-2-git-send-email-jiri@resnulli.us>
	<20140515084342.1aaae42a@nehalam.linuxnetplumber.net>
	<20140515165051.GA2939@minipsycho.orion>
	<20140516205816.180bf3ac@nehalam.linuxnetplumber.net>
	<20140517085031.GA3006@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mschmidt@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:49880 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbaFITr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 15:47:58 -0400
Received: by mail-pb0-f43.google.com with SMTP id up15so5297995pbc.16
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 12:47:58 -0700 (PDT)
In-Reply-To: <20140517085031.GA3006@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 May 2014 10:50:31 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Sat, May 17, 2014 at 05:58:16AM CEST, stephen@networkplumber.org wrote:
> >On Thu, 15 May 2014 18:50:51 +0200
> >Jiri Pirko <jiri@resnulli.us> wrote:
> >
> >> Thu, May 15, 2014 at 05:43:42PM CEST, stephen@networkplumber.org wrote:
> >> >On Thu, 15 May 2014 15:10:20 +0200
> >> >Jiri Pirko <jiri@resnulli.us> wrote:
> >> >
> >> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> >> >> ---
> >> >>  misc/arpd.c | 6 +++---
> >> >>  1 file changed, 3 insertions(+), 3 deletions(-)
> >> >> 
> >> >
> >> >Why not use more standard ether_ntoa ?
> >> 
> >> Because the rest of the code uses ll_addr_n2a. There is no user of
> >> ether_ntoa in iproute2.
> >
> >arpd is more of a standalone program.
> 
> I know but it is a part of the package (git tree). The other instances
> use ll_addr_n2a. I'm ok with using ether_ntoa, I just wanted to follow
> what is already there.
> 
> I can change it and post v2 it you want. I can also change other instances
> of usage ll_addr_n2a to ether_ntoa.
> 
> 

This is fine, just went ahead and merged this version.
