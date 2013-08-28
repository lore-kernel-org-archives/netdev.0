From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v3 0/13] bonding: remove vlan special handling
Date: Wed, 28 Aug 2013 23:24:27 +0200
Message-ID: <20130828212426.GA21704@redhat.com>
References: <1377705842-8276-1-git-send-email-vfalico@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:15421 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755815Ab3H1VZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 17:25:48 -0400
Content-Disposition: inline
In-Reply-To: <1377705842-8276-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 28, 2013 at 06:03:49PM +0200, Veaceslav Falico wrote:
>v1: Per Jiri's advice, remove the exported netdev_upper struct to keep it
>    inside dev.c only, and instead implement a macro to iterate over the
>    list and return only net_device *.
>v2: Jiri noted that we need to see every upper device, but not only the
>    first level. Modify the netdev_upper logic to include a list of lower
>    devices and for both upper/lower lists every device would see both its
>    first-level devices and every other devices that is lower/upper of it.
>    Also, convert some annoying spamming warnings to pr_debug in
>    bond_arp_send_all.
>v3: move renaming part completely to patch 1 (did I forget to git add
>    before commiting?) and address Jiri's input about comments/style of
>    patch 2.

Self-NAK for this patchset, sent the new version with a bug corrected.

Thanks all for the review.
