From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [BUGFIX PATCH] net: ethernet: cpsw: fix erroneous condition in
 error check
Date: Thu, 21 Mar 2013 18:02:21 +0530
Message-ID: <514AFDD5.9020608@ti.com>
References: <1363868411-25318-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: =?UTF-8?B?TG90aGFyIFdhw59tYW5u?= <LW@KARO-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363868411-25318-1-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/21/2013 5:50 PM, Lothar Wa=C3=9Fmann wrote:
> The error check in cpsw_probe_dt() has an '&&' where an '||' is
> meant to be. This causes a NULL pointer dereference when incomplet DT
> data is passed to the driver ('phy_id' property for cpsw_emac1
> missing).
>
>
> Signed-off-by: Lothar Wa=C3=9Fmann<LW@KARO-electronics.de>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
