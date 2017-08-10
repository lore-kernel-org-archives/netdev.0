From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] net-next: dsa: fix flow dissection
Date: Wed, 09 Aug 2017 22:52:43 -0700 (PDT)
Message-ID: <20170809.225243.2204411285392662424.davem@davemloft.net>
References: <20170809124119.24320-1-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, sean.wang@mediatek.com,
        netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        linux-kernel@vger.kernel.org, muciri@openmesh.com,
        shashidhar.lakkavalli@openmesh.com
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809124119.24320-1-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Wed,  9 Aug 2017 14:41:15 +0200

> RPS and probably other kernel features are currently broken on some if not
> all DSA devices. The root cause of this is that skb_hash will call the
> flow_dissector. At this point the skb still contains the magic switch
> header and the skb->protocol field is not set up to the correct 802.3
> value yet. By the time the tag specific code is called, removing the header
> and properly setting the protocol an invalid hash is already set. In the
> case of the mt7530 this will result in all flows always having the same
> hash.
> 
> Changes since RFC:
> * use a callback instead of static values
> * add cover letter

Series applied, thanks.
