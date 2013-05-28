From: Joe Perches <joe@perches.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Mon, 27 May 2013 23:08:53 -0700
Message-ID: <1369721333.22004.24.camel@joe-AO722>
References: <1369599557-22677-1-git-send-email-atomlin@redhat.com>
	 <51A39A3F.8080903@redhat.com> <1369693520.3301.477.camel@edumazet-glaptop>
	 <1369715506.2034.30.camel@joe-AO722>
	 <1369721054.3301.531.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rik van Riel <riel@redhat.com>, atomlin@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	aquini@redhat.com, sergei.shtylyov@cogentembedded.com,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369721054.3301.531.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-27 at 23:04 -0700, Eric Dumazet wrote:
> If dump_stack are scary, they are scary for every k[mz]alloc() users,
> not only __alloc_skb_alloc()

True, but perhaps they are relatively rarer though
for non net use cases.
