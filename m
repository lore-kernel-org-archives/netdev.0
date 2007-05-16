From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Wed, 16 May 2007 16:15:51 -0700
Message-ID: <1179357351.10414.18.camel@w-sridhar2.beaverton.ibm.com>
References: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com>
	 <1178911773.4126.26.camel@localhost> <1178972280.4061.7.camel@localhost>
	 <4645F325.3060607@trash.net>  <1178999773.15622.44.camel@localhost>
	 <1179066518.15622.60.camel@localhost> <1179149418.15622.79.camel@localhost>
	 <1179356104.4084.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:59505 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755753AbXEPXPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 19:15:55 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4GNFs30028113
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 19:15:54 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4GNFsRV490056
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 19:15:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4GNFq6C030057
	for <netdev@vger.kernel.org>; Wed, 16 May 2007 19:15:54 -0400
In-Reply-To: <1179356104.4084.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-16 at 18:55 -0400, jamal wrote:
> On Mon, 2007-14-05 at 09:30 -0400, jamal wrote:
> > Incoporating last comments from Patrick.
> > Dave, I think this is ready to apply - against net-2.6 from this
> > morning. 
> 
> Dave - hold onto this patch - Sridhar Samudrala <sri@us.ibm.com> caught
> a bug i need to fix (GSO wont work).

I think your qdisc_restart() cleanup patch is OK. There you are
still calling dev_hard_start_xmit() and GSO should work fine.

But the batch xmit patch has some issues.

Thanks
Sridhar

> The game starting in a few holds priority for now. I will send a patch
> either tonight or tommorow morning.
> Otoh, if you have applied it - it is a simple incremental patch.
> 
> cheers,
> jamal


