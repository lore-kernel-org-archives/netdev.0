From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 0/6] bonding: only rely on arp packets if arp
 monitor is used
Date: Fri, 17 Jan 2014 18:07:56 +0100
Message-ID: <20140117170755.GL1896@redhat.com>
References: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
 <15764.1389848997@death.nxdomain>
 <20140116084102.GM1867@redhat.com>
 <21868.1389911939@death.nxdomain>
 <20140117065718.GA5699@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965AbaAQRKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 12:10:55 -0500
Content-Disposition: inline
In-Reply-To: <20140117065718.GA5699@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 07:57:18AM +0100, Veaceslav Falico wrote:
...snip...
>What do you think about this*? It's on top of this series, extends
>arp_validate to (not) filter out ARPs on not-validated slaves and permits
>it to be used in non-AB mode (also, we don't need that bond->lock, we're
>always under RCU).

Hi Jay,

In the meanwhile I've integrated this approach (adding new arp_validate
options) and sent v2.

The new version, when used with arp_validate=0/1/2/3 (old values) behaves
exactly the same, while adding 3 new options - only unvalidated ARPs,
validated ARPs on active and unvalidated ARPs on slave and vice versa
(there's no analogue for ALL_ARP cause it doesn't make much sense - as the
validated ARPs for both slaves are already ARPs :) ).

Hope that helps, and sorry that I didn't do my homework in the first time.

Thank you!
