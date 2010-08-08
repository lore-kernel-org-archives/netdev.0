From: Fabio Comolli <fabio.comolli@gmail.com>
Subject: Latest iproute2 breaks "ip route get" command
Date: Sun, 8 Aug 2010 19:02:56 +0200
Message-ID: <AANLkTi=e8sNB6MYuRfOBjf0cyDOHNsu3-sJatb2iv7y+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47841 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712Ab0HHRC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 13:02:57 -0400
Received: by bwz3 with SMTP id 3so772546bwz.19
        for <netdev@vger.kernel.org>; Sun, 08 Aug 2010 10:02:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good morning.

The following logs should explain the problem. In short, the "ip route
get" command with iproute2 v. 2.6.35 does not output anything (and
exits with a 0). This breaks (for example) vpnc.

If I use iproute2 v. 2.6.34 everything is OK. This is with a 2.6.35 kernel.

Note: this happens not only using the default Archlinux package but
also if I download and compile the sources.

Please let me know if you need more details.

Best regards,
Fabio


---------------------------------------------------------------------------------------------------------------------------------------------
[root@ratbert] - [/var/cache/pacman/pkg] nslookup www.google.com
Server:		8.8.8.8
Address:	8.8.8.8#53

Non-authoritative answer:
www.google.com	canonical name = www.l.google.com.
Name:	www.l.google.com
Address: 72.14.234.104

[root@ratbert] - [/var/cache/pacman/pkg] ip route get  72.14.234.104
72.14.234.104 via 192.168.1.1 dev wlan0  src 192.168.1.69
    cache  mtu 1500 advmss 1460 hoplimit 64
[root@ratbert] - [/var/cache/pacman/pkg] pacman -U
iproute2-2.6.35-1-i686.pkg.tar.xz
resolving dependencies...
looking for inter-conflicts...

Targets (1): iproute2-2.6.35-1

Total Download Size:    0.00 MB
Total Installed Size:   1.27 MB

Proceed with installation? [Y/n]
checking package integrity...
(1/1) checking for file conflicts

[############################################################] 100%
(1/1) upgrading iproute2

[############################################################] 100%
[root@ratbert] - [/var/cache/pacman/pkg] ip route get  72.14.234.104
[root@ratbert] - [/var/cache/pacman/pkg]
-------------------------------------------------------------------------------------------------------------------------------------------------
