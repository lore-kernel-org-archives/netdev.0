From: Ilan Tayari <ilant@mellanox.com>
Subject: RE: IPv6 IPSec incompatibilities between 2.6.23 and 3.6.18 (and
 probably later)
Date: Tue, 19 Jul 2016 15:03:33 +0000
Message-ID: <AM4PR0501MB19408B7B4BBFDE17EB980F74DB370@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <DD56476BFBBCB94EA5C5CCFF543EBEC99A0DEB52@ExMbx1.iabg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Pommnitz_J=F6rg?= <Pommnitz@iabg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0056.outbound.protection.outlook.com ([104.47.2.56]:37896
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752217AbcGTHLW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 03:11:22 -0400
In-Reply-To: <DD56476BFBBCB94EA5C5CCFF543EBEC99A0DEB52@ExMbx1.iabg.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > On the receiving side (e.g. fd01:1b10:1000::1) I see the decrypted packets with
> the 2.6.23 kernel:
> but NOT with the newer kernel:

Hi Joerg,

First steps to debug this would be:
cat /proc/net/xfrm_stat
ip -s xfrm state
ip -s xfrm policy

First command will show some error accounting, which can point to the culprit code.
Second and third command will show existing objects, and some statistics like when the last packet was used with them.

Last thing - for your safety you should keep those session keys private.

Ilan.
