From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv4 net-next 2/3] sunvnet: allow admin to set sunvnet MTU
Date: Wed, 17 Sep 2014 09:07:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17494244@AcuExch.aculab.com>
References: <541785D8.5030101@oracle.com> <541886B9.3010206@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David L Stevens' <david.stevens@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38608 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751754AbaIQJJH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 05:09:07 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23153-03 for <netdev@vger.kernel.org>;
 Wed, 17 Sep 2014 10:08:56 +0100 (BST)
In-Reply-To: <541886B9.3010206@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens
> On 09/15/2014 08:35 PM, David L Stevens wrote:
> 
> >   */
> >  #define VNET_TX_TIMEOUT			(5 * HZ)
> >
> > -#define VNET_MAXPACKET			1518ULL /* ETH_FRAMELEN + VLAN_HDR */
> > +#define VNET_MAXPACKET			65553ULL /* 64K-1  +ETH HDR +VLAN HDR*/

That would be better as the expression (0xffffull + 14 + 4).

> >  #define VNET_TX_RING_SIZE		512
> >  #define VNET_TX_WAKEUP_THRESH(dr)	((dr)->pending / 4)

	David
