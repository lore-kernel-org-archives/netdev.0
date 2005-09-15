From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] hippi: change to not use skb private
Date: Thu, 15 Sep 2005 09:21:45 -0700
Message-ID: <20050915092145.4ea4d069@dxpl.pdx.osdl.net>
References: <20050913113858.440d3a0f@localhost.localdomain>
	<20050914.210316.32480446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jes@trained-monkey.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030519AbVIOQVe@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050914.210316.32480446.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Sep 2005 21:03:16 -0700 (PDT)
"David S. Miller" <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Tue, 13 Sep 2005 11:38:58 -0700
> 
> > It looks like the following would fix hippi to not have to put
> > fields in sk_buff. The ifield looks appears to to be additional
> > header information that is being passed in the skb but could just
> > be put in the header.
> 
> Stephen this patch is against 2.6.13 or something.  We already
> put this thing into a SKB control block for 2.6.14-rc1.  Do you
> want to keep things that way or update your patch for 2.6.14-rc1?

Sorry, I was cleaning up the old unfinished work pile. The new version
(using header) is better than the cb version because it is cleaner
and doesn't have the nasty error handling issues of reallocating
header in the transmit routine.
