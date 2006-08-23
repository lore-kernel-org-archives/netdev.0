From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Wed, 23 Aug 2006 18:09:12 +0200
Message-ID: <20060823180912.2f06d469@griffin.suse.cz>
References: <20060822173241.313859000@devicescape.com>
	<20060822173419.GF12500@devicescape.com>
	<1156317906.3629.18.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:35731 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S965015AbWHWQJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 12:09:13 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1156317906.3629.18.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Aug 2006 09:25:06 +0200, Johannes Berg wrote:
> Should that really drop dataframes dead on the floor? And wouldn't it
> make sense stop the networking layer from injecting more data into the
> stack when stop_data_frame_tx is enabled?

I agree. That should be solved in an another way (stop dequeuing frames
from 802.11 qdisc?).

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
