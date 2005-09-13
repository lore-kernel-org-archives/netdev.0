From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] hippi: change to not use skb private
Date: Tue, 13 Sep 2005 13:54:16 -0700 (PDT)
Message-ID: <20050913.135416.112398983.davem@davemloft.net>
References: <20050913113858.440d3a0f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jes@trained-monkey.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932524AbVIMUyT@vger.kernel.org>
To: shemminger@osdl.org
In-Reply-To: <20050913113858.440d3a0f@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 13 Sep 2005 11:38:58 -0700

> It looks like the following would fix hippi to not have to put
> fields in sk_buff. The ifield looks appears to to be additional
> header information that is being passed in the skb but could just
> be put in the header.

I can't see any problem with this patch, and it fixes
all the realloc stuff that has to potentially occur
in the transmit path.
