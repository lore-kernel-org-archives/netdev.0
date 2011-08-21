From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 0/2] Improve sequence number generation.
Date: Sat, 20 Aug 2011 23:27:53 -0400
Message-ID: <20110821032753.GA8992@thunk.org>
References: <20110821012844.GA15222@1wt.eu>
 <20110821030415.18106.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: w@1wt.eu, dan@doxpara.com, davem@davemloft.net,
	gerrit@erg.abdn.ac.uk, herbert@gondor.hengli.com.au,
	linux-kernel@vger.kernel.org, mpm@selenic.com,
	netdev@vger.kernel.org
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li9-11.members.linode.com ([67.18.176.11]:41381 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752301Ab1HUD2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Aug 2011 23:28:13 -0400
Content-Disposition: inline
In-Reply-To: <20110821030415.18106.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a random thought --- it won't help on anything other than
modern x86's, but who's to say we have to use the same algorithm on
all platforms?  Does the AES-NI facility provide enough of a speedup
that it's worth using it instead of MD5, at least on modern x86
systems which have this support?

					- Ted
