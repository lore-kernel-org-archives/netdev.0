From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: lan9303: Only allocate 3 ports
Date: Tue, 08 Aug 2017 18:14:18 -0700 (PDT)
Message-ID: <20170808.181418.2139412071619210859.davem@davemloft.net>
References: <20170807222221.28963-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: privat@egil-hjelmeland.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807222221.28963-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Date: Tue,  8 Aug 2017 00:22:21 +0200

> Save 2628 bytes on arm eabi by allocate only the required 3 ports.
> 
> Now that ds->num_ports is correct: In net/dsa/tag_lan9303.c
> eliminate duplicate LAN9303_MAX_PORTS, use ds->num_ports.
> (Matching the pattern of other net/dsa/tag_xxx.c files.)
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Applied.
