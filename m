From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 4/6] d80211: don't display name of invisible network
 device
Date: Thu, 1 Feb 2007 16:17:11 +0100
Message-ID: <20070201161711.37373b18@griffin.suse.cz>
References: <20070129174809.6401B48499@silver.suse.cz>
	<1170164845.30318.19.camel@johannes.berg>
	<58d0dbf10701300600h24cdb9b8xabbc27b16d4ddb05@mail.gmail.com>
	<1170269938.2236.1.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jan Kiszka <jan.kiszka@googlemail.com>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:33703 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030568AbXBAPR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 10:17:27 -0500
In-Reply-To: <1170269938.2236.1.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Jan 2007 19:58:58 +0100, Johannes Berg wrote:
> Well, that's a bug indeed, but the cure isn't "don't allow any qos
> operations" but rather "don't allow removal of the 802.11 qdisc".

This solution can be described as "don't allow 802.11 qdisc
customization for now, introduce that as a new feature later when
qdiscs and netdev are not tied together".

It solves several problems by stripping down just one feature (which
hardly anybody uses now and which is not working properly anyway) which
will be reintroduced later. Quite feasible I would say given the fact
that userspace-visible master network interface is perceived as a merge
blocker by some people.

 Jiri

-- 
Jiri Benc
SUSE Labs
