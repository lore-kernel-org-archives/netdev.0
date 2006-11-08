From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/11] convert d80211 to a proper protocol
Date: Wed, 08 Nov 2006 13:53:29 +0100
Message-ID: <1162990409.7567.33.camel@ux156>
References: <1162741174.24574.22.camel@johannes.berg>
	 <20061106210145.6824bec6@griffin.suse.cz>
	 <1162854394.1412.40.camel@johannes.berg>
	 <20061108130933.7284558a@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	David Kimdon <david.kimdon@devicescape.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:10893 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965613AbWKHMwZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 07:52:25 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061108130933.7284558a@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-08 at 13:09 +0100, Jiri Benc wrote:

> Unfortunately, in case of broadcast and multicast frames, we probably
> need to go through decryption handlers for each interface individually.
> At least I wasn't able to find a solution which allows to perform
> decryption only once for each frame. But theoretically it should be
> possible but I'm afraid it would be less effective than the current
> situation in the end.

Yeah, I can see the point, even though it seems that we can only decrypt
a frame with a single key, everything else will be invalid.

Maybe we can filter somehow and find which key to use instead of
filtering to the interface first... will need to think about it.

johannes
