From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Wed, 27 Mar 2013 08:11:43 -0700
Message-ID: <874nfwri6o.fsf@xmission.com>
References: <CD78B3C3.76D3%blourdel@juniper.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Serge Hallyn <serge.hallyn@ubuntu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Benoit Lourdelet <blourdel@juniper.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:36272 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885Ab3C0PL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 11:11:56 -0400
In-Reply-To: <CD78B3C3.76D3%blourdel@juniper.net> (Benoit Lourdelet's message
	of "Wed, 27 Mar 2013 13:37:45 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benoit Lourdelet <blourdel@juniper.net> writes:

> Hello Serge,
>
> I am indeed using Eric patch with lxc.
>
> It solves the initial problem of slowness to start around 1600
> containers.

Good so now we just need a production ready patch for iproute.

> I am now able to start more than  2000 without having new containers
> slower and slower to start.

May I ask how large a box you are running and how complex your
containers are.  I am trying to get a feel for how common it is likely
to be to find people running thousands of containers on a single
machine.

Eric
