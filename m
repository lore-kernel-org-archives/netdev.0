From: Patrick McHardy <kaber@trash.net>
Subject: Re: Traffic Control - Burst 4096Mb ?!
Date: Wed, 18 Jun 2008 12:26:22 +0200
Message-ID: <4858E2CE.5020605@trash.net>
References: <BD53B6560CD66B4AA230BBB09CD2C8F3244275@ags-exch.ags-intranet.net> <BD53B6560CD66B4AA230BBB09CD2C8F346DB91@ags-exch.ags-intranet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean-Philippe RAMES <jprames@ags-backup.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59204 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbYFRK00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 06:26:26 -0400
In-Reply-To: <BD53B6560CD66B4AA230BBB09CD2C8F346DB91@ags-exch.ags-intranet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jean-Philippe RAMES wrote:
> Hello,
>  
> I don't understand why when I run:
> tc class add dev eth2 parent 2:1 classid 2:85 htb rate 1024bit ceil
> 1mbit burst 30kb prio 5
> 
> the burst becomes 4096Mb (tc class show eth2):
> class htb 2:85 parent 2:1 prio 5 rate 1024bit ceil 1000Kbit burst 4096Mb
> cburst 2100b
> 
> And I've noticed if I run the same command with a different rate:
> tc class add dev eth2 parent 2:1 classid 2:85 htb rate 256kbit ceil
> 1mbit burst 30kb prio 5
> 
> the 30kb burst appears correctly:
> class htb 2:85 parent 2:1 prio 5 rate 1024bit ceil 1000Kbit burst 30kb
> cburst 2100b

Which iproute version are you using?

