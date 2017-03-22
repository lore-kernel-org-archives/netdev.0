From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] NAPI ID fixups related to busy polling
Date: Wed, 22 Mar 2017 11:26:29 -0700 (PDT)
Message-ID: <20170322.112629.1655081687167143481.davem@davemloft.net>
References: <20170320214643.13922.51284.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sridhar.samudrala@intel.com, edumazet@google.com
To: alexander.duyck@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170320214643.13922.51284.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 20 Mar 2017 14:48:41 -0700

> These two patches are a couple of minor clean-ups related to busy polling.
> The first one addresses the fact that we were trying to busy poll on
> sender_cpu values instead of true NAPI IDs.  The second addresses the fact
> that there were a few paths where TCP sockets were being instanciated based
> on a received patcket, but not recording the hash or NAPI ID of the packet
> that was used to instanciate them.

I'm expecting a respin of this.  Patch #1 appears to be 'net' material, and
Eric asked for some other minor tweaks as well.

Thanks.
