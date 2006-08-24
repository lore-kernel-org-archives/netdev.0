From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH wireless-dev 4/6] d80211: Send Layer 2 Update frames in kernel
Date: Wed, 23 Aug 2006 22:39:30 -0700
Message-ID: <20060824053930.GB6104@jm.kir.nu>
References: <20060807231608.888744720@localhost> <20060807231938.455373487@localhost> <20060823192256.3e8df7f9@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.genealogia.fi ([194.100.116.229]:45253 "EHLO
	mail2.genealogia.fi") by vger.kernel.org with ESMTP
	id S1030300AbWHXFkj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 01:40:39 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060823192256.3e8df7f9@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 23, 2006 at 07:22:56PM +0200, Jiri Benc wrote:
> On Mon, 07 Aug 2006 16:16:12 -0700, Jouni Malinen wrote:
> > Send Layer 2 Update frame from the 802.11 code in kernel to the netdev
> > that the STA is bound to. If the STA is bound to another VLAN netdev,
> > send another update frame. This fixes an issue in which a local bridge
> > table was not updated when hostapd sent this frame.
> 
> I hope someone is going to describe why is this necessary and why it
> cannot be done in a less hackish way. Otherwise, I'd probably tend to
> ask for reverting this patch.

Which part do you think is hackish here? Sending the layer 2 update
frame or moving it to kernel?

-- 
Jouni Malinen                                            PGP id EFC895FA
