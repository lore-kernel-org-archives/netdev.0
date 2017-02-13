From: Arvid Brodin <arvid.brodin@alten.se>
Subject: Re: Linux HSR driver question
Date: Mon, 13 Feb 2017 16:38:58 +0100
Message-ID: <58A1D312.2030003@alten.se>
References: <589CD1F5.1060104@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.webland.nu ([37.26.152.130]:55944 "HELO mx01.webland.nu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
        id S1751313AbdBMPyR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 10:54:17 -0500
In-Reply-To: <589CD1F5.1060104@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-02-09 21:32, Murali Karicheri wrote:
> Hi Arvid,
> 
> While I work to add PRP support to the existing Linux HSR driver, I came across
> a piece of code related to prune node function. The hsr_device.c adds the 
> prune timer in hsr_dev_finalize() by calling
> 
> add_timer(&hsr->prune_timer);
> 
> But it is never restarted in hsr_prune_nodes(). Is that intentional or a bug?
> I tried adding add_timer(&hsr->prune_timer) at the end of  hsr_prune_nodes(),
> but then a iperf test stops with no traffic across the hsr interface and it
> never recovers. I have to delete the interface and create it again to recover.
> Is that the reason, it is currently disabled?
> 

Hi Murali,

Sorry I don't remember the details here. I do know I tested that a node that had
been unplugged for two minutes was forgotten by the other nodes, so this has 
worked at some time in the past, at least. :)


-- 
Arvid Brodin
Linux Consultant
ALTEN Sweden
