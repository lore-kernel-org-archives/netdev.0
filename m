From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: move slave MTU handling from
 sysfs V2
Date: Wed, 02 Jun 2010 03:40:34 -0700 (PDT)
Message-ID: <20100602.034034.146365447.davem@davemloft.net>
References: <20100518154016.GD2878@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, monis@voltaire.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33766
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755178Ab0FBKkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 06:40:24 -0400
In-Reply-To: <20100518154016.GD2878@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 18 May 2010 17:42:40 +0200

> V1->V2: corrected res/ret use
> 
> For some reason, MTU handling (storing, and restoring) is taking  place in
> bond_sysfs. The correct place for this code is in bond_enslave, bond_release.
> So move it there.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
