From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev] d80211: Don't discriminate against 802.11b
 drivers
Date: Fri, 12 May 2006 12:47:03 +0200
Message-ID: <20060512124703.563dacd6@griffin.suse.cz>
References: <200605042232.35446.flamingice@sourmilk.net>
	<20060511175426.72ae7744@griffin.suse.cz>
	<200605101331.39960.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Jouni Malinen" <jkm@devicescape.com>, netdev@vger.kernel.org,
	jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:16306 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751021AbWELKrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 May 2006 06:47:05 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200605101331.39960.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 May 2006 13:31:39 -0400, Michael Wu wrote:
> I think this is overkill to fix a hack. IMHO, scan_skip_11b shouldn't exist in 
> the first place. One alternative would be to modify 802.11g drivers to not 
> set IEEE80211_CHAN_W_SCAN on 802.11b channels when there are equivalent 
> 802.11g channels.

This won't work when 11g is administratively disabled. We can surely add
another flags; but I'm not sure if it is really desirable to require
drivers to be aware of this when it is easily determinable by the stack.

> It seems like hw_modes is more useful for saying 
> what modes shouldn't be used than saying what modes are supported by the 
> hardware and should be used.

This is exactly the purpose of hw_modes. This also means you don't need
any validation.

 Jiri

-- 
Jiri Benc
SUSE Labs
