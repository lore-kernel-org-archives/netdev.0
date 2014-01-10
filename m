From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 1/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of IP6 routes
Date: Fri, 10 Jan 2014 04:56:03 +0100
Message-ID: <20140110035603.GA1012@order.stressinduktion.org>
References: <20140108200019.GK9007@order.stressinduktion.org> <1389227404-12586-1-git-send-email-thaller@redhat.com> <1389227404-12586-2-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53040 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaAJD4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 22:56:05 -0500
Content-Disposition: inline
In-Reply-To: <1389227404-12586-2-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 09, 2014 at 01:30:03AM +0100, Thomas Haller wrote:
> When adding/modifying an IPv6 address, the userspace application needs
> a way to suppress adding a prefix route. This is for example relevant
> together with IFA_F_MANAGERTEMPADDR, where userspace creates autoconf
> generated addresses, but depending on on-link, no route for the
> prefix should be added.
> 
> Signed-off-by: Thomas Haller <thaller@redhat.com>

Looks good!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
