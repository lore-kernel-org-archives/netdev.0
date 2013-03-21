From: David Miller <davem@davemloft.net>
Subject: Re: [BUGFIX PATCH] net: ethernet: cpsw: fix erroneous condition in
 error check
Date: Thu, 21 Mar 2013 11:57:57 -0400 (EDT)
Message-ID: <20130321.115757.176260167306171131.davem@davemloft.net>
References: <1363868411-25318-1-git-send-email-LW@KARO-electronics.de>
	<514AFDD5.9020608@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LW@KARO-electronics.de, richardcochran@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <514AFDD5.9020608@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Mugunthan V N <mugunthanvnm@ti.com>
Date: Thu, 21 Mar 2013 18:02:21 +0530

> On 3/21/2013 5:50 PM, Lothar Wa=DFmann wrote:
>> The error check in cpsw_probe_dt() has an '&&' where an '||' is
>> meant to be. This causes a NULL pointer dereference when incomplet D=
T
>> data is passed to the driver ('phy_id' property for cpsw_emac1
>> missing).
>>
>>
>> Signed-off-by: Lothar Wa=DFmann<LW@KARO-electronics.de>
> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
