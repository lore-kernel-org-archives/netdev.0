From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: move dev_addr cpy to bond_enslave
Date: Wed, 02 Jun 2010 04:17:14 -0700 (PDT)
Message-ID: <20100602.041714.236244214.davem@davemloft.net>
References: <20100519111428.GA2788@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39679
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751550Ab0FBLRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 07:17:04 -0400
In-Reply-To: <20100519111428.GA2788@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 19 May 2010 13:14:29 +0200

> Move the code that copies slave's mac address in case that's the first slave into
> bond_enslave. Ifenslave app does this also but that's not a problem. This is
> something that should be done in bond_enslave, and it shound not matter from
> where is it called.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

(Jiri, please number your patches in a set, even if they should apply
 properly independantly, thanks)

Applied.
