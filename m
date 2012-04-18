From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [net-next PATCH v3] bonding: start slaves with link down for
 ARP monitor
Date: Wed, 18 Apr 2012 16:19:12 -0300
Message-ID: <20120418161912.1c0e2f4e@asterix.rh>
References: <20120417121135.5F9A740290@alaris.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522Ab2DRTUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2012 15:20:06 -0400
In-Reply-To: <20120417121135.5F9A740290@alaris.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Apr 2012 14:02:06 +0200
Michal Kubecek <mkubecek@suse.cz> wrote:

> Initialize slave device link state as down if ARP monitor is
> active and net_carrier_ok() returns zero. Also shift initial
> value of its last_arp_tx so that it doesn't immediately cause
> fake detection of "up" state.
> 
> When ARP monitoring is used, initializing the slave device with
> up link state can cause ARP monitor to detect link failure
> before the device is really up (with igb driver, this can take
> more than two seconds).
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Signed-off-by: Flavio Leitner <fbl@redhat.com>

fbl
