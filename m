From: Krzysztof Oledzki <olel@ans.pl>
Subject: TCP port randomization
Date: Wed, 17 Oct 2007 23:15:48 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710172308140.12701@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-542308699-1192655748=:12701"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:37176 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760195AbXJQVQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 17:16:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-542308699-1192655748=:12701
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

Hello,

Is it normal that TCP port randomization (tested with 2.6.22) works only=20
when explicitly binding to a IP address:


--- cut here ---
root@fw1:~# nc 192.168.129.28 11
(UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
root@fw1:~# nc 192.168.129.28 11
(UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
root@fw1:~# nc 192.168.129.28 11
(UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused

23:11:11.896126 IP 192.168.129.2.37839 > 192.168.129.28.11: S
23:11:12.146573 IP 192.168.129.2.37840 > 192.168.129.28.11: S
23:11:12.396488 IP 192.168.129.2.37841 > 192.168.129.28.11: S
--- cut here ---


--- cut here ---
root@fw1:~# nc -s 192.168.129.2 192.168.129.28 11
(UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
root@fw1:~# nc -s 192.168.129.2 192.168.129.28 11
(UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
root@fw1:~# nc -s 192.168.129.2 192.168.129.28 11
(UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused

23:11:31.704391 IP 192.168.129.2.57204 > 192.168.129.28.11: S
23:11:34.400048 IP 192.168.129.2.14512 > 192.168.129.28.11: S
23:11:34.606707 IP 192.168.129.2.20117 > 192.168.129.28.11: S
--- cut here ---

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-542308699-1192655748=:12701--
