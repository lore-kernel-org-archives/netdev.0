From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: napi fix
Date: Wed, 12 Dec 2007 07:22:12 -0800 (PST)
Message-ID: <20071212.072212.106556355.davem@davemloft.net>
References: <20071211213939.122de1db@freepuppy.rosehill>
	<20071211214634.4dedb274@freepuppy.rosehill>
	<b25c3fa70712112205l2e778bacx66470606272b199@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	baum@tehutinetworks.net, andy@greyhouse.net
To: joonwpark81@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758384AbXLLPW2@vger.kernel.org>
In-Reply-To: <b25c3fa70712112205l2e778bacx66470606272b199@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Joonwoo Park" <joonwpark81@gmail.com>
Date: Wed, 12 Dec 2007 15:05:26 +0900

> Could you explain how it fix the problem?
> IMHO I think your patch cannot solve the problem.
> The drivers can call netif_rx_complete and net_rx_action can do
> list_move_tail also.

Stephen is confused about what the bug is in these drivers,
that's all.
