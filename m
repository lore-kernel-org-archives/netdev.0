From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
 properly in bridge
Date: Wed, 18 Mar 2009 23:20:03 -0700 (PDT)
Message-ID: <20090318.232003.30974750.davem@davemloft.net>
References: <20090314094911.GA3455@psychotron.englab.brq.redhat.com>
	<20090315161217.7fa2c3a7@nehalam>
	<20090316111127.GB3484@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: jpirko@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759299AbZCSGUc@vger.kernel.org>
In-Reply-To: <20090316111127.GB3484@psychotron.englab.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 16 Mar 2009 12:11:28 +0100

> I can see two solutions. Either like my patch or somehow allow bridge to know
> more MAC addressses per port (maybe netdev can be changed to know more then
> one MAC address).
> 
> Any thoughts?

The netdev struct already supports having a list of multiple unicast
MAC addresses, it can probably be used and inspected for this.

I'll hold off on your patch until we make some more progress on
this discussion.
