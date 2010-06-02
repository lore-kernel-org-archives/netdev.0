From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] bonding: move dev_addr cpy to bond_enslave
Date: Wed, 2 Jun 2010 13:20:22 +0200
Message-ID: <20100602112021.GA2607@psychotron.lab.eng.brq.redhat.com>
References: <20100519111428.GA2788@psychotron.lab.eng.brq.redhat.com>
 <20100602.041714.236244214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19613 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846Ab0FBLUd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 07:20:33 -0400
Content-Disposition: inline
In-Reply-To: <20100602.041714.236244214.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 02, 2010 at 01:17:14PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Wed, 19 May 2010 13:14:29 +0200
>
>> Move the code that copies slave's mac address in case that's the first slave into
>> bond_enslave. Ifenslave app does this also but that's not a problem. This is
>> something that should be done in bond_enslave, and it shound not matter from
>> where is it called.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>(Jiri, please number your patches in a set, even if they should apply
> properly independantly, thanks)

Sorry, this was not ment to be a set. I was just posting patches as I went thru
the code. Will try to "buffer" it next time.

Thanks.

>
>Applied.
