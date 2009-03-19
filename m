From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
	properly in bridge
Date: Thu, 19 Mar 2009 12:19:28 +0100
Message-ID: <20090319111927.GD4123@psychotron.englab.brq.redhat.com>
References: <20090316111127.GB3484@psychotron.englab.brq.redhat.com> <20090318.232003.30974750.davem@davemloft.net> <20090319084444.GA4123@psychotron.englab.brq.redhat.com> <20090319.032143.08849045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54144 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338AbZCSLVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 07:21:00 -0400
Content-Disposition: inline
In-Reply-To: <20090319.032143.08849045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 19, 2009 at 11:21:43AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Thu, 19 Mar 2009 09:44:45 +0100
>
>> Yes I was looking at this thing yesterday (uc_list). But this list serves
>> to different purpose. Do you think that it will be correct to use it for this? I
>> would maybe like to make a new list similar to this for our purpose
>> (say addr_list). I think it would be more correct.
>
>Whatever you do with that list privately inside of the bonding
>driver should be fine.
Well I do not need it only inside the bonding driver. I want bridge to use this
list when adding a device in it and get mac addresses from there into its
hashlist (to recognize these addresses as local).
>
>It might upset something in the generic code if you don't clean
>it up before deregistration of the bonding device, so just be
>tidy.
