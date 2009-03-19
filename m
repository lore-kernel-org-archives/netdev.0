From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
	properly in bridge
Date: Thu, 19 Mar 2009 09:44:45 +0100
Message-ID: <20090319084444.GA4123@psychotron.englab.brq.redhat.com>
References: <20090314094911.GA3455@psychotron.englab.brq.redhat.com> <20090315161217.7fa2c3a7@nehalam> <20090316111127.GB3484@psychotron.englab.brq.redhat.com> <20090318.232003.30974750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36954 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbZCSIrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 04:47:14 -0400
Content-Disposition: inline
In-Reply-To: <20090318.232003.30974750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 19, 2009 at 07:20:03AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Mon, 16 Mar 2009 12:11:28 +0100
>
>> I can see two solutions. Either like my patch or somehow allow bridge to know
>> more MAC addressses per port (maybe netdev can be changed to know more then
>> one MAC address).
>> 
>> Any thoughts?
>
>The netdev struct already supports having a list of multiple unicast
>MAC addresses, it can probably be used and inspected for this.
Yes I was looking at this thing yesterday (uc_list). But this list serves
to different purpose. Do you think that it will be correct to use it for this? I
would maybe like to make a new list similar to this for our purpose
(say addr_list). I think it would be more correct.

Eventually in the furute we would use this list as a primary place to store
device address instead of dev_addr value and make it more general (as device
generally may have more adresses). Just a thought...

>
>I'll hold off on your patch until we make some more progress on
>this discussion.
