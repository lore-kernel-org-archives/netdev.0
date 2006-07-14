From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Netem does not work with loopback
Date: Fri, 14 Jul 2006 08:38:47 -0700
Message-ID: <20060714083847.6997a460@localhost.localdomain>
References: <44B7AB76.2030700@yahoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58271 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161123AbWGNPi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 11:38:57 -0400
To: Guillaume Chazarain <guichaz@yahoo.fr>
In-Reply-To: <44B7AB76.2030700@yahoo.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Jul 2006 16:34:30 +0200
Guillaume Chazarain <guichaz@yahoo.fr> wrote:

> Hello,
> 
> Is it a known problem that the Netem qdisc is very unreliable on the 
> loopback (unlike on a true NIC)?
> 
> This seems to come from its usage of skb->cb which conflicts with IPCB. 
> For instance, the field
> IPCB(skb)->opt.optlen becomes non-null and memory corruption follows.
> 
> I ``worked around'' this conflict with the following ugly hack:

Isn't the skb owned by netem at that point...

-- 
If one would give me six lines written by the hand of the most honest
man, I would find something in them to have him hanged. -- Cardinal Richlieu
