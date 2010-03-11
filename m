From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: vlan JMicron Technologies, Inc. JMC250 PCI Express Gigabit
 Ethernet
Date: Thu, 11 Mar 2010 08:54:12 -0800
Message-ID: <20100311085412.3413d44b@nehalam>
References: <4B9914A9.2050207@cost.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vito Mattera <vito.m@cost.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41481 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933360Ab0CKRUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 12:20:50 -0500
In-Reply-To: <4B9914A9.2050207@cost.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Mar 2010 17:04:57 +0100
Vito Mattera <vito.m@cost.it> wrote:

> I'm trying to add vlan using the network adapter  JMC250 in CentOS 5.3
> with the driver: kmod-jme-1.0.5-1.el5.elrepo.i686.rpm
> 
> 
> when I type the command:
> vconfig add eth0 3
> 
> I have the following message:
> 
> 
> 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
> register_vlan_device: Device eth0 has buggy VLAN hw accel
> 
> and no vlan is created.
> 
> what is my mistake ?

Message happens if driver sets hardware vlan filtering but
provides no callback.
The driver appears okay in upstream kernel, most likely something
got lost in backport process in redhat or the copying of redhat
done by centos.
