From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: pppd soft lockups under load
Date: Fri, 7 Mar 2008 10:13:09 +0000
Message-ID: <20080307101309.GB4203@ff.dom.local>
References: <47D05778.6090006@samoylyk.sumy.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Oleksandr Samoylyk <oleksandr@samoylyk.sumy.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:47759 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbYCGKLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 05:11:49 -0500
Received: by fg-out-1718.google.com with SMTP id e21so461924fga.17
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2008 02:11:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47D05778.6090006@samoylyk.sumy.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06-03-2008 21:43, Oleksandr Samoylyk wrote:
> Dear community,
> 
> I'm running a busy pptp-server which serves about 1500 users on about 80 
> Mbit/s (> 15000 packets/sec). I use poptop, traffic shaper and basic 
> firewall rules.
> 
> As for hardware it's a server on SuperMicro Server on X7DB8+ serverboard 
> server with 8 GB RAM on it running Ubuntu Server Edition.
> 
> As for problem, sometimes I get the following erors in logs:
> [    0.000000] BUG: soft lockup - CPU#3 stuck for 11s! [pppd:65437]
...
> root@vpn:~# cat /proc/interrupts
>            CPU0       CPU1       CPU2       CPU3       CPU4       CPU5 
>       CPU6       CPU7
...
> 2296:      76853      76976      76639      76692     248073     247957 
>     248079     248084   PCI-MSI-edge      eth1
> 2297:     266795     266672     267009     266956      93920      94035 
>      93914      93908   PCI-MSI-edge      eth0

Hi,

Maybe it doesn't matter here but I think you should rethink this
irq balancing for eths. Here is something interesting:

http://marc.info/?l=linux-netdev&m=120349568512423&w=2

Regards,
Jarek P.
