From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 0/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of IP6 routes
Date: Tue, 7 Jan 2014 17:03:28 +0100
Message-ID: <20140107160328.GF24730@order.stressinduktion.org>
References: <1389029375-17698-1-git-send-email-thaller@redhat.com> <1389105553-21230-1-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45551 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbaAGQD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 11:03:29 -0500
Content-Disposition: inline
In-Reply-To: <1389105553-21230-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 03:39:11PM +0100, Thomas Haller wrote:
> Now, the IFA_F_NOPREFIXROUTE flag is saved in ifp->flags.
> The second patch reworks the deletion of addresses/cleanup of prefix
> routes and considers IFA_F_NOPREFIXROUTE.
> 
> Thomas Haller (2):
>   ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of
>     IP6 routes
>   ipv6 addrconf: don't cleanup route prefix for IFA_F_NOPREFIXROUTE

Maybe you could look into if a small patch implementing noprefixroute would be
doable. That would help testing these changes a lot. ;)

Greetings,

  Hannes
