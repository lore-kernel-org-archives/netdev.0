From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev 4/6] d80211: Send Layer 2 Update frames in
 kernel
Date: Thu, 24 Aug 2006 13:43:16 +0200
Message-ID: <20060824134316.5f5a0746@griffin.suse.cz>
References: <20060807231608.888744720@localhost>
	<20060807231938.455373487@localhost>
	<20060823192256.3e8df7f9@griffin.suse.cz>
	<20060824053930.GB6104@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:60627 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751158AbWHXLnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 07:43:17 -0400
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20060824053930.GB6104@jm.kir.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Aug 2006 22:39:30 -0700, Jouni Malinen wrote:
> Which part do you think is hackish here? Sending the layer 2 update
> frame or moving it to kernel?

The latter.

Is it really needed to send it unconditionally for each added STA? And
cannot it be generated in userspace?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
