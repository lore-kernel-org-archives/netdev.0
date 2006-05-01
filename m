From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] vlan: add sysfs support
Date: Mon, 1 May 2006 15:26:37 -0700
Message-ID: <20060501152637.012fc67b@localhost.localdomain>
References: <20060501140834.43a006fd@localhost.localdomain>
	<44568692.6020409@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	vlan@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15258 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932305AbWEAW0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 18:26:46 -0400
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <44568692.6020409@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 01 May 2006 15:07:14 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Stephen Hemminger wrote:
> > Add basic sysfs support for vlan device. It creates an entry in the
> > vlan pseudo-device to display tag.  
> > 	/sys/class/net/eth0.5/vlan_id
> 
> Looks fine to me, though I don't know enough about sysfs to notice
> any bugs with it...
> 
> I do have a question:  Will this work for > 256 vlans?
> 
> /proc had a limit of around 256 directories last I
> checked, so just curious.
> 
> Thanks,
> Ben
> 

There should be no limits caused by sysfs...
