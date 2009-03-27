From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
	properly in bridge -try4
Date: Fri, 27 Mar 2009 08:46:55 +0100
Message-ID: <20090327074654.GC3377@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090326155205.GA28868@psychotron.englab.brq.redhat.com> <20090327.003819.234492275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, dada1@cosmosbay.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58091 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751823AbZC0Ht2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2009 03:49:28 -0400
Content-Disposition: inline
In-Reply-To: <20090327.003819.234492275.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 27, 2009 at 08:38:19AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Thu, 26 Mar 2009 16:52:06 +0100
>
>> (resend, updated changelog, hook moved into skb_bond_should_drop,
>> skb_bond_should_drop ifdefed)
>> 
>> Hi all.
>> 
>> The problem is described in following bugzilla:
>> https://bugzilla.redhat.com/show_bug.cgi?id=487763
> ...
>> This patch solves the situation in the bonding without touching bridge code,
>> as Patrick suggested. For every incoming frame to bonding it searches the
>> destination address in slaves list and if any of slave addresses matches, it
>> rewrites the address in frame by the adress of bonding master. This ensures that
>> all frames comming thru the bonding in alb mode have the same address.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>
>I don't like the hook, but if that's how it's best done....

Yes I agree with you, but I thing that for now it's the best way to do this. I
picked this solution out of 3 that I had in mind and this is the lesser evil :)
If anyone have any other solution please speak up.

>
>Patrick, please review this.
