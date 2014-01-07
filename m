From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 2/2] ipv6 addrconf: don't cleanup route prefix for IFA_F_NOPREFIXROUTE
Date: Tue, 7 Jan 2014 17:28:47 +0100
Message-ID: <20140107162847.GB30393@order.stressinduktion.org>
References: <1389029375-17698-1-git-send-email-thaller@redhat.com> <1389105553-21230-1-git-send-email-thaller@redhat.com> <1389105553-21230-3-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45630 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbaAGQ2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 11:28:48 -0500
Content-Disposition: inline
In-Reply-To: <1389105553-21230-3-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 03:39:13PM +0100, Thomas Haller wrote:
> Also, when adding the NOPREFIXROUTE flag to an already existing address,
> check if there there is a prefix that was likly added by the kernel
> and delete it.

Hmm, could you give a bit more details why you have done this? I find
that a bit counterintuitive. Maybe it has a reason?
