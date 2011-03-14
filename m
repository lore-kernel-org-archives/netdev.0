From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] NET: cdc-phonet, fix stop-queue handling
Date: Mon, 14 Mar 2011 15:23:34 -0700 (PDT)
Message-ID: <20110314.152334.27803075.davem@davemloft.net>
References: <1300035271-8138-1-git-send-email-jslaby@suse.cz>
	<201103140939.57056.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jslaby@suse.cz, jirislaby@gmail.com, netdev@vger.kernel.org,
	gregkh@suse.de, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201103140939.57056.remi.denis-courmont@nokia.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Mon, 14 Mar 2011 09:39:56 +0200

> On Sunday 13 March 2011 18:54:30 ext Jiri Slaby, you wrote:
>> Currently there is a warning emitted by the cdc-phonet driver:
>> WARNING: at include/linux/netdevice.h:1557 usbpn_probe+0x3bb/0x3f0
>> [cdc_phonet]() Modules linked in: ...
>> Pid: 5877, comm: insmod Not tainted 2.6.37.3-16-desktop #1
>> Call Trace:
>>  [<ffffffff810059b9>] dump_trace+0x79/0x340
>>  [<ffffffff81520fdc>] dump_stack+0x69/0x6f
>>  [<ffffffff810580eb>] warn_slowpath_common+0x7b/0xc0
>>  [<ffffffffa00254fb>] usbpn_probe+0x3bb/0x3f0 [cdc_phonet]
>> ...
>> ---[ end trace f5d3e02908603ab4 ]---
>> netif_stop_queue() cannot be called before register_netdev()
>>=20
>> So remove netif_stop_queue from the probe funtction to avoid that.
>>=20
>> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
>> Cc: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>> Cc: David S. Miller <davem@davemloft.net>
>=20
> Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
