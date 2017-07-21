From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: Re: [PATCH v2 0/4] RGMII RX and TX clock delays using Atheros 8035
Date: Fri, 21 Jul 2017 15:16:04 +0200
Message-ID: <2cbfd70a-70db-f3d7-40d0-3adc4f56a8d1@sigmadesigns.com>
References: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
 <2711b987-a9db-e1d0-5346-a9d43309aaa2@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([216.205.24.107]:30904 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750762AbdGUNQL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 09:16:11 -0400
In-Reply-To: <2711b987-a9db-e1d0-5346-a9d43309aaa2@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/07/2017 14:47, Marc Gonzalez wrote:

> fping caps at 1000 packets per second, which limits
> its usefulness as a benchmarking tool.

"Normal" ping is slightly faster (5000 packets per second).

time ping -f -c 60000 -s 1450 -q 172.27.64.1

--- 172.27.64.1 ping statistics ---
60000 packets transmitted, 60000 received, 0% packet loss, time 12059ms
rtt min/avg/max/mdev = 0.159/0.167/3.536/0.021 ms, ipg/ewma 0.201/0.166 ms

real    0m12.067s
user    0m0.899s
sys     0m1.886s

NIC statistics:
     rx_bytes_ok: 89760375
     rx_frames_ok: 60003
     rx_undersize_frames: 0
     rx_fragment_frames: 0
     rx_64_byte_frames: 2
     rx_127_byte_frames: 0
     rx_255_byte_frames: 1
     rx_511_byte_frames: 0
     rx_1023_byte_frames: 0
     rx_max_size_frames: 60000
     rx_oversize_frames: 0
     rx_bad_fcs_frames: 0
     rx_broadcast_frames: 1
     rx_multicast_frames: 0
     rx_control_frames: 0
     rx_pause_frames: 0
     rx_unsup_control_frames: 0
     rx_align_error_frames: 0
     rx_overrun_frames: 0
     rx_jabber_frames: 0
     rx_bytes: 89760375
     rx_frames: 60003
     tx_bytes_ok: 89760128
     tx_frames_ok: 60002
     tx_64_byte_frames: 2
     tx_127_byte_frames: 0
     tx_255_byte_frames: 0
     tx_511_byte_frames: 0
     tx_1023_byte_frames: 0
     tx_max_size_frames: 60000
     tx_oversize_frames: 0
     tx_broadcast_frames: 1
     tx_multicast_frames: 0
     tx_control_frames: 0
     tx_pause_frames: 0
     tx_underrun_frames: 0
     tx_single_collision_frames: 0
     tx_multi_collision_frames: 0
     tx_deferred_collision_frames: 0
     tx_late_collision_frames: 0
     tx_excessive_collision_frames: 0
     tx_bytes: 89760128
     tx_frames: 60002
     tx_collisions: 0
