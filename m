From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Thu, 28 Mar 2013 16:52:51 -0700
Message-ID: <87zjxn84ks.fsf@xmission.com>
References: <20130328150410.GA22789@sergelap>
	<CD7A1D9A.78BA%blourdel@juniper.net>
	<20130328152040.2c905ad9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benoit Lourdelet <blourdel@juniper.net>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45720 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951Ab3C1XxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 19:53:04 -0400
In-Reply-To: <20130328152040.2c905ad9@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Thu, 28 Mar 2013 15:20:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> Try the following two patches. It adds a name hash list, and uses Eric's idea
> to avoid loading map on add/delete operations.

On my microbenchmark of just creating 5000 veth pairs this takes pairs
16s instead of 13s of my earlier hacks but that is well down in the
usable range.

Deleting all of those network interfaces one by one takes me 60s.

So on the microbenchmark side this looks like a good improvement and
pretty usable.

I expect Benoit's container startup workload will also reflect this, but
it will be interesting to see the actual result.

Eric
