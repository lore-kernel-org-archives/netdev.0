From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 0/4] net-next: dsa: fix flow dissection
Date: Wed, 09 Aug 2017 11:07:28 -0400
Message-ID: <87h8xghj9r.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170809124119.24320-1-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        linux-kernel@vger.kernel.org, Muciri Gatimu <muciri@openmesh.com>,
        Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>,
        John Crispin <john@phrozen.org>
To: John Crispin <john@phrozen.org>, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809124119.24320-1-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

John Crispin <john@phrozen.org> writes:

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
>
> John Crispin (4):
>   net-next: dsa: move struct dsa_device_ops to the global header file
>   net-next: dsa: add flow_dissect callback to struct dsa_device_ops
>   net-next: tag_mtk: add flow_dissect callback to the ops struct
>   net-next: dsa: fix flow dissection

The "net-next" tag goes into the subject-prefix, i.e.
"[PATCH net-next v3 0/4]" (this is the result of git format-patch
--subject-prefix="PATCH net-next" -v3 --cover-letter.)

The commit title prefix represents the most impacted subsystem, here
"net: dsa: xxx" would map the net/dsa/ or drivers/net/dsa directories.

Other than that, the whole patchset LGTM:

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>


Thanks,

        Vivien
