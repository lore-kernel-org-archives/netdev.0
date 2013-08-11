From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question about netif_rx
Date: Sun, 11 Aug 2013 11:56:09 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1308111151210.2072@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: romieu@fr.zoreil.com, grant.likely@linaro.org,
	rob.herring@calxeda.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To my limited understanding, in a NAPI polling function, one should use 
netif_receive_skb, rather than netif_rx.  However, the via-velocity driver 
defines the NAPI polling function velocity_poll, which is the only caller 
of velocity_rx_srv, which is the only caller of velocity_receive_frame, 
which calls netif_rx.  The call to netif_rx seems to predate the 
introduction of NAPI in this driver.  Is this correct?

thanks,
julia
