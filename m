From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 0/13] bonding: remove vlan special handling
Date: Wed, 28 Aug 2013 18:04:02 +0200
Message-ID: <20130828160402.GJ1992@redhat.com>
References: <1377691352-4146-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54051 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328Ab3H1QG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 12:06:28 -0400
Content-Disposition: inline
In-Reply-To: <1377691352-4146-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 28, 2013 at 02:02:19PM +0200, Veaceslav Falico wrote:
>v1: Per Jiri's advice, remove the exported netdev_upper struct to keep it
>    inside dev.c only, and instead implement a macro to iterate over the
>    list and return only net_device *.
>v2: Jiri noted that we need to see every upper device, but not only the
>    first level. Modify the netdev_upper logic to include a list of lower
>    devices and for both upper/lower lists every device would see both its
>    first-level devices and every other devices that is lower/upper of it.
>    Also, convert some annoying spamming warnings to pr_debug in
>    bond_arp_send_all.

Self-NAK on this patchset, will send the updated v3 in a few moments.
