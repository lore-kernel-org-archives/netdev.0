From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 1/3] iproute2: arpd: use ll_addr_a2n and
 ll_addr_n2a
Date: Fri, 16 May 2014 20:58:16 -0700
Message-ID: <20140516205816.180bf3ac@nehalam.linuxnetplumber.net>
References: <1400159422-11797-1-git-send-email-jiri@resnulli.us>
	<1400159422-11797-2-git-send-email-jiri@resnulli.us>
	<20140515084342.1aaae42a@nehalam.linuxnetplumber.net>
	<20140515165051.GA2939@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mschmidt@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:43530 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755785AbaEQD6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 23:58:20 -0400
Received: by mail-pb0-f48.google.com with SMTP id rr13so3409960pbb.35
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 20:58:19 -0700 (PDT)
In-Reply-To: <20140515165051.GA2939@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2014 18:50:51 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Thu, May 15, 2014 at 05:43:42PM CEST, stephen@networkplumber.org wrote:
> >On Thu, 15 May 2014 15:10:20 +0200
> >Jiri Pirko <jiri@resnulli.us> wrote:
> >
> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> >> ---
> >>  misc/arpd.c | 6 +++---
> >>  1 file changed, 3 insertions(+), 3 deletions(-)
> >> 
> >
> >Why not use more standard ether_ntoa ?
> 
> Because the rest of the code uses ll_addr_n2a. There is no user of
> ether_ntoa in iproute2.

arpd is more of a standalone program.
