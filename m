From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Is veth in net-next reordering traffic?
Date: Wed, 06 May 2015 20:16:57 -0700
Message-ID: <1430968617.14545.103.camel@edumazet-glaptop2.roam.corp.google.com>
References: <554AC83F.7070609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34770 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbbEGDQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 23:16:59 -0400
Received: by iget9 with SMTP id t9so3581222ige.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 20:16:58 -0700 (PDT)
In-Reply-To: <554AC83F.7070609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-06 at 19:04 -0700, Rick Jones wrote:
> I've been messing about with a setup approximating what an OpenStack 
> Nova Compute node creates for the private networking plumbing when using 
> OVX+VxLAN.  Just without the VM.  So, I have a linux bridge (named qbr), 
> a veth pair (named qvb and qvo) joining that to an OVS switch (called 
> br-int) which then has a patch pair joining that OVS bridge to another 
> OVS bridge (br-tun) which has a vxlan tunnel defined.

veth can certainly reorder traffic, unless you use cpu binding with your
netperf (sender side)
