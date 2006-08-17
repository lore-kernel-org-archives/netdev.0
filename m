From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev 4/6] d80211: Send Layer 2 Update frames in
 kernel
Date: Thu, 17 Aug 2006 15:20:50 +0200
Message-ID: <20060817152050.6b64bacc@griffin.suse.cz>
References: <20060807231608.888744720@localhost>
	<20060807231938.455373487@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkm@devicescape.com, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:32212 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932479AbWHQNUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 09:20:52 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060807231938.455373487@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 07 Aug 2006 16:16:12 -0700, Jouni Malinen wrote:
> Send Layer 2 Update frame from the 802.11 code in kernel to the netdev
> that the STA is bound to. If the STA is bound to another VLAN netdev,
> send another update frame. This fixes an issue in which a local bridge
> table was not updated when hostapd sent this frame.

This seems like a hack to me. Isn't there some netlink mechanism that
can be used instead?

 Jiri

-- 
Jiri Benc
SUSE Labs
