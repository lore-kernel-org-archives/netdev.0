From: Moshe Shemesh <moshe@mellanox.com>
Subject: RE: [PATCH net-next 4/4] net/mlx4_core: Add an option to configure
 SVLAN TPID
Date: Sun, 10 Jul 2016 12:04:59 +0000
Message-ID: <AM4PR0501MB22288385E246DD0324E258EBD93E0@AM4PR0501MB2228.eurprd05.prod.outlook.com>
References: <1467808146-29573-1-git-send-email-tariqt@mellanox.com>
 <1467808146-29573-5-git-send-email-tariqt@mellanox.com>
 <CAJ3xEMho+6W_r3kEuq2+tCD1FZfW0M0xJzS-VGLUD9fK17u+1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Ariel Almog <ariela@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
	Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0047.outbound.protection.outlook.com ([104.47.2.47]:55296
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757180AbcGJTk5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 15:40:57 -0400
In-Reply-To: <CAJ3xEMho+6W_r3kEuq2+tCD1FZfW0M0xJzS-VGLUD9fK17u+1Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>On Wed, Jul 6, 2016 at 3:29 PM, Tariq Toukan <tariqt@mellanox.com> wrote:
>> From: Moshe Shemesh <moshe@mellanox.com>
>>
>> Expose mlx4_config_svlan_tpid, that checks for feature support in 
>> device capabilities and sets the Service Tag TPID accordingly.
>
>I Googled for service tag TPID and I understand this is what we can vlan protcol, correct? any reason to >call it differently?

No, it is not the vlan protocol.
It is the ethertype used on the external vlan and the correct term is TPID.

> dead code? I don't see any invocation of this helper on the patch, if it's on earlier patches of the series it means you broke bisection...

I will recheck about that.

Regards,
Moshe.
