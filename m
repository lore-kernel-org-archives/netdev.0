From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] vlan: add sysfs support
Date: Mon, 01 May 2006 15:07:14 -0700
Message-ID: <44568692.6020409@candelatech.com>
References: <20060501140834.43a006fd@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	vlan@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:32459 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932296AbWEAWHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 18:07:22 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060501140834.43a006fd@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Add basic sysfs support for vlan device. It creates an entry in the
> vlan pseudo-device to display tag.  
> 	/sys/class/net/eth0.5/vlan_id

Looks fine to me, though I don't know enough about sysfs to notice
any bugs with it...

I do have a question:  Will this work for > 256 vlans?

/proc had a limit of around 256 directories last I
checked, so just curious.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

