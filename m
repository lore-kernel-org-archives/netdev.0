From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH} ARP auto-sizing for 2.4.24 - 2.4.26-pre3
Date: Mon, 15 Mar 2004 13:44:12 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040315134412.314b5e23.davem@redhat.com>
References: <200403141210.57266.timg@tpi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: timg@tpi.com
In-Reply-To: <200403141210.57266.timg@tpi.com>
List-Id: netdev.vger.kernel.org


Two problems:

1) Don't do the config option thing if we're going to auto-size.

2) Your ram_mb calcs use PAGE_SIZE as a term, and therefore assume
   it has a value of 4096 or somesuch.  Please remove this assumption.

To be honest, while I'm not against making the tables a little bigger,
for ARP "WHO THE FUCK CARES" if another 100 cycles or so are burnt on
a lookup.  What setup do you have where ARP performance is a real issue?

Your original email was nice in describing the fact that ARP does not
scale, but you've made no foundation on which to erect a claim that
scalability for ARP (and thus the added complexity/changes) is even
necessary.
