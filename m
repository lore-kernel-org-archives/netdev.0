From: "Jean-Philippe RAMES" <jprames@ags-backup.com>
Subject: RE: Traffic Control - Burst 4096Mb ?!
Date: Wed, 18 Jun 2008 12:16:45 +0200
Message-ID: <BD53B6560CD66B4AA230BBB09CD2C8F346DB91@ags-exch.ags-intranet.net>
References: <BD53B6560CD66B4AA230BBB09CD2C8F3244275@ags-exch.ags-intranet.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.ags-backup.com ([195.101.79.129]:23825 "EHLO
	exchange.ags-backup.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbYFRKRZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 06:17:25 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
 
I don't understand why when I run:
tc class add dev eth2 parent 2:1 classid 2:85 htb rate 1024bit ceil
1mbit burst 30kb prio 5

the burst becomes 4096Mb (tc class show eth2):
class htb 2:85 parent 2:1 prio 5 rate 1024bit ceil 1000Kbit burst 4096Mb
cburst 2100b

And I've noticed if I run the same command with a different rate:
tc class add dev eth2 parent 2:1 classid 2:85 htb rate 256kbit ceil
1mbit burst 30kb prio 5

the 30kb burst appears correctly:
class htb 2:85 parent 2:1 prio 5 rate 1024bit ceil 1000Kbit burst 30kb
cburst 2100b
 
Thanks for your help,
JP.
