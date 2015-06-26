From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Re: Issue with LACP mode in linux bonding driver
Date: Fri, 26 Jun 2015 19:27:38 +0530
Message-ID: <CADAe=+LmF_O5Tw_+kcg35urKBjJJOFZrYs3R2LNkdh-XW6r2ng@mail.gmail.com>
References: <CADAe=+LvNgHV+crN_+E4xB+Pcz=KSvZpK5ADKzYFjHL2gGJq2Q@mail.gmail.com>
 <6462.1435284902@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:34822 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbbFZN6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 09:58:19 -0400
Received: by oiax193 with SMTP id x193so75782232oia.2
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 06:58:17 -0700 (PDT)
In-Reply-To: <6462.1435284902@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 June 2015 at 07:45, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
> echo 'module bonding =p' > /sys/kernel/debug/dynamic_debug/control
Hi,

thanks for the reply.

Linux server (enp0s8)(bond0) ======== (po1)(xe1) switch
Linux server (enp0s9)(bond0) ======== (po2)(xe2) switch

I have tried the steps mentioned in the previous mail. But I can only
see RX state machine related logs as shown below

[14775.575048] bonding: Received LACPDU on port 2
[14775.575051] bonding: Rx Machine: Port=2, Last State=6, Curr State=6
[14775.638060] bonding: Received LACPDU on port 1
[14775.638063] bonding: Rx Machine: Port=1, Last State=6, Curr State=6
[14775.650975] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14775.750280] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14775.850771] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14775.950817] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14776.052255] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14776.155483] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14776.259759] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14776.360020] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14776.462303] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14776.560375] bonding: Received LACPDU on port 2
[14776.560378] bonding: Rx Machine: Port=2, Last State=6, Curr State=6
[14776.562899] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14776.622476] bonding: Received LACPDU on port 1
[14776.622478] bonding: Rx Machine: Port=1, Last State=6, Curr State=6
[14776.665981] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14776.767769] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14776.867544] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14776.967442] bonding: Periodic Machine: Port=1, Last State=3, Curr State=4
[14776.967510] bonding: Sent LACPDU on port 1
[14776.967524] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14777.068075] bonding: Periodic Machine: Port=1, Last State=4, Curr State=3
[14777.068080] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14777.169102] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14777.270426] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14777.371119] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14777.473184] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14777.542800] bonding: Received LACPDU on port 2
[14777.542837] bonding: Rx Machine: Port=2, Last State=6, Curr State=6
[14777.574911] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14777.604569] bonding: Received LACPDU on port 1
[14777.604599] bonding: Rx Machine: Port=1, Last State=6, Curr State=6
[14777.674451] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14777.774171] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14777.875429] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14777.976074] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14778.077979] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14778.179497] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14778.280577] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14778.382005] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14778.484380] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14778.528073] bonding: Received LACPDU on port 2
[14778.528076] bonding: Rx Machine: Port=2, Last State=6, Curr State=6
[14778.582553] bonding: Periodic Machine: Port=2, Last State=3, Curr State=4
[14778.582641] bonding: Sent LACPDU on port 2
[14778.586482] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14778.588507] bonding: Received LACPDU on port 1
[14778.588509] bonding: Rx Machine: Port=1, Last State=6, Curr State=6
[14778.682574] bonding: Periodic Machine: Port=2, Last State=4, Curr State=3
[14778.686117] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14778.788289] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14778.890620] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14778.993106] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14779.093547] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14779.195574] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14779.296085] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14779.398869] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14779.499408] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14779.527556] bonding: Received LACPDU on port 2
[14779.527559] bonding: Rx Machine: Port=2, Last State=6, Curr State=6
[14779.587923] bonding: Received LACPDU on port 1
[14779.587927] bonding: Rx Machine: Port=1, Last State=6, Curr State=6
[14779.599856] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14779.700372] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14779.800274] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14779.900126] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14780.000140] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14780.100073] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14780.202081] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14780.304725] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14780.404988] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14780.505805] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14780.521825] bonding: Received LACPDU on port 2
[14780.521829] bonding: Rx Machine: Port=2, Last State=6, Curr State=6
[14780.580985] bonding: Received LACPDU on port 1
[14780.580989] bonding: Rx Machine: Port=1, Last State=6, Curr State=6
[14780.606091] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14780.706416] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14780.807086] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14780.907126] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14781.008729] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14781.109174] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14781.210017] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14781.312609] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14781.413590] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14781.513075] bonding: bond_should_notify_peers: bond bond0 slave enp0s8
[14781.519042] bonding: Received LACPDU on port 2
[14781.519045] bonding: Rx Machine: Port=2, Last State=6, Curr State=6
[14781.577600] bonding: Received LACPDU on port 1
[14781.577628] bonding: Rx Machine: Port=1, Last State=6, Curr State=6


I am even attaching the tcpdump log on back to back connected links
below as the lacpdu generated from linux server has collecting
distributing bit set as TRUE.

LACPDU generated by switch
19:15:33.941161 08:00:27:81:1e:a1 (oui Unknown) > 01:80:c2:00:00:02
(oui Unknown), ethertype Slow Protocols (0x8809), length 124: LACPv1,
length 110
        Actor Information TLV (0x01), length 20
          System 08:00:27:46:4d:1d (oui Unknown), System Priority
32768, Key 2, Port 4, Port Priority 32768
          State Flags [Activity, Aggregation, Synchronization,
Collecting, Distributing]
        Partner Information TLV (0x02), length 20
          System 08:00:27:18:ae:4b (oui Unknown), System Priority
65535, Key 17, Port 2, Port Priority 255
          State Flags [Activity, Timeout, Aggregation,
Synchronization, Collecting, Distributing]
        Collector Information TLV (0x03), length 16
          Max Delay 5
        Terminator TLV (0x00), length 0

LACPDU generated by linux server
19:15:34.718987 08:00:27:76:35:a2 (oui Unknown) > 01:80:c2:00:00:02
(oui Unknown), ethertype Slow Protocols (0x8809), length 124: LACPv1,
length 110
        Actor Information TLV (0x01), length 20
          System 08:00:27:18:ae:4b (oui Unknown), System Priority
65535, Key 17, Port 2, Port Priority 255
          State Flags [Activity, Timeout, Aggregation,
Synchronization, Collecting, Distributing]
        Partner Information TLV (0x02), length 20
          System 08:00:27:46:4d:1d (oui Unknown), System Priority
32768, Key 2, Port 4, Port Priority 32768
          State Flags [Activity, Aggregation, Synchronization,
Collecting, Distributing]
        Collector Information TLV (0x03), length 16
          Max Delay 0
        Terminator TLV (0x00), length 0

===================================================

LACPDU generated by switch
19:20:08.246164 08:00:27:81:50:43 (oui Unknown) > 01:80:c2:00:00:02
(oui Unknown), ethertype Slow Protocols (0x8809), length 124: LACPv1,
length 110
        Actor Information TLV (0x01), length 20
          System 08:00:27:46:4d:1d (oui Unknown), System Priority
32768, Key 1, Port 3, Port Priority 32768
          State Flags [Activity, Aggregation, Synchronization,
Collecting, Distributing]
        Partner Information TLV (0x02), length 20
          System 08:00:27:18:ae:4b (oui Unknown), System Priority
65535, Key 17, Port 1, Port Priority 255
          State Flags [Activity, Timeout, Aggregation,
Synchronization, Collecting, Distributing]
        Collector Information TLV (0x03), length 16
          Max Delay 5
        Terminator TLV (0x00), length 0

LACPDU generated by linux server
19:20:08.611534 08:00:27:18:ae:4b (oui Unknown) > 01:80:c2:00:00:02
(oui Unknown), ethertype Slow Protocols (0x8809), length 124: LACPv1,
length 110
        Actor Information TLV (0x01), length 20
          System 08:00:27:18:ae:4b (oui Unknown), System Priority
65535, Key 17, Port 1, Port Priority 255
          State Flags [Activity, Timeout, Aggregation,
Synchronization, Collecting, Distributing]
        Partner Information TLV (0x02), length 20
          System 08:00:27:46:4d:1d (oui Unknown), System Priority
32768, Key 1, Port 3, Port Priority 32768
          State Flags [Activity, Aggregation, Synchronization,
Collecting, Distributing]
        Collector Information TLV (0x03), length 16
          Max Delay 0
        Terminator TLV (0x00), length 0

Regards,
Ajith
