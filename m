From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: does the broadcom bnx2x support RSS/multi queue
Date: Wed, 12 May 2010 09:41:59 +0200
Message-ID: <1273650119.2621.5.camel@edumazet-laptop>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85D43@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:33573 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241Ab0ELHmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 03:42:05 -0400
Received: by wwi18 with SMTP id 18so576091wwi.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 00:42:01 -0700 (PDT)
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85D43@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 mai 2010 =C3=A0 00:31 -0700, Jon Zhou a =C3=A9crit :
> hi there
>=20
> I am not sure if my Broadcom 10G nic driver(bnx2x) support RSS/multi =
queue
>=20
> ibm-bc-53:/home/ruizhou/nprobe # uname -a
> Linux ibm-bc-53 2.6.27.19-5-default #1 SMP 2009-02-28 04:40:21 +0100 =
x86_64 x86_64 x86_64 GNU/Linux
>=20
> ibm-bc-53:/home/ruizhou/nprobe # ethtool -S eth5
> NIC statistics:
>      rx_bytes: 68100170
>      rx_error_bytes: 0
>      tx_bytes: 0
>      tx_error_bytes: 0
>      rx_ucast_packets: 201654
>      rx_mcast_packets: 0
>      rx_bcast_packets: 0
>      tx_packets: 0
>      tx_mac_errors: 0
>      tx_carrier_errors: 0
>      rx_crc_errors: 0
>      rx_align_errors: 0
>      tx_single_collisions: 0
>      tx_multi_collisions: 0
>      tx_deferred: 0
>      tx_excess_collisions: 0
>      tx_late_collisions: 0
>      tx_total_collisions: 0
>      rx_fragments: 0
>      rx_jabbers: 0
>      rx_undersize_packets: 0
>      rx_oversize_packets: 0
>      tx_64_byte_packets: 0
>      tx_65_to_127_byte_packets: 0
>      tx_128_to_255_byte_packets: 0
>      tx_256_to_511_byte_packets: 0
>      tx_512_to_1023_byte_packets: 0
>      tx_1024_to_1522_byte_packets: 0
>      tx_1523_to_9022_byte_packets: 0
>      rx_xon_frames: 0
>      rx_xoff_frames: 0
>      tx_xon_frames: 0
>      tx_xoff_frames: 0
>      rx_mac_ctrl_frames: 0
>      rx_filtered_packets: 0
>      rx_discards: 0
>      rx_fw_discards: 0
>      brb_discard: 0
>      brb_truncate: 0
>      rx_phy_ip_err_discards: 0
>      rx_skb_alloc_discard: 0
>      rx_csum_offload_errors: 6
>=20
> the driver ver is:
> bnx2x_main.c
> #define DRV_MODULE_VERSION      "1.45.26"
>=20
> looks not support?
>=20
> thanks
> jon

Per queue stats were added last year only (Thu Feb 12 08:36:33 2009)

You might check "grep eth5 /proc/interrupts"

Or upgrade to 2.6.33.x kernel :)


