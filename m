From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] net: dsa: move fixed link registration helpers
Date: Sat, 28 Oct 2017 18:59:07 +0900 (KST)
Message-ID: <20171028.185907.1273095115511794061.davem@redhat.com>
References: <20171026145007.17583-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026145007.17583-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 26 Oct 2017 10:50:07 -0400

> The new bindings (dsa2.c) and the old bindings (legacy.c) share two
> helpers dsa_cpu_dsa_setup and dsa_cpu_dsa_destroy, used to register or
> deregister a fixed PHY if a given port has a corresponding device node.
> 
> Unclutter the code by moving them into two new port.c helpers,
> dsa_port_fixed_link_register_of and dsa_port_fixed_link_(un)register_of.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks Vivien.
