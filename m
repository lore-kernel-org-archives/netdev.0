From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next] bonding: add min links parameter to 802.3ad
Date: Wed, 22 Jun 2011 21:58:06 -0400
Message-ID: <20110623015806.GO21309@gospo.rdu.redhat.com>
References: <20110622105408.06fd4788@nehalam.ftrdhcpuser.net> <4E02452E.2030307@redhat.com> <20110622125439.44e47a2c@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Flavio Leitner <fbl@redhat.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62914 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758391Ab1FWB6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 21:58:21 -0400
Content-Disposition: inline
In-Reply-To: <20110622125439.44e47a2c@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2011 at 12:54:39PM -0700, Stephen Hemminger wrote:
> This adds support for a configuring the minimum number of links that
> must be active before asserting carrier. It is similar to the Cisco
> EtherChannel min-links feature. This allows setting the minimum number
> of member ports that must be up (link-up state) before marking the
> bond device as up (carrier on). This is useful for situations where
> higher level services such as clustering want to ensure a minimum
> number of low bandwidth links are active before switchover.
> 
> See:
>    http://bugzilla.vyatta.com/show_bug.cgi?id=7196
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> v2 - need to transition to carrier_off if insufficient number of links
>      and whitespace cleanup
> 

Looks good.  Thanks for fixing bond_3ad_set_carrier.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
