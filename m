From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: getting VF link info seems to be broken in 3.9-rc8
Date: Wed, 24 Apr 2013 19:34:44 +0300
Message-ID: <517809A4.3070001@mellanox.com>
References: <5177D946.9080704@mellanox.com> <20130424083825.00004f94@unknown> <20130424090133.00005ca6@unknown> <A3A921390EAE4044940E99EBF13D97322426359F@FMSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>, Rony Efraim <ronye@mellanox.com>
To: "Li, Sibai" <sibai.li@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog121.obsmtp.com ([207.126.144.151]:43334 "EHLO
	eu1sys200aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756128Ab3DXQew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 12:34:52 -0400
In-Reply-To: <A3A921390EAE4044940E99EBF13D97322426359F@FMSMSX104.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/04/2013 19:08, Li, Sibai wrote:
> The vfs are listed, eth22/eth20. Just the mac address is different. Reload the  vf driver to see if it corrects the thing.

Sure, the VF are listed as NICs of their own, what's isn't listed is the 
VF info from the PF NIC link info, e.g here's the casewhere its working, 
on kernel 3.8.8-- my problem isn't the MAC misalignment

8: eth11: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state 
DOWN mode DEFAULT qlen 1000
     link/ether 00:1b:21:55:1d:00 brd ff:ff:ff:ff:ff:ff
     vf 0 MAC 00:11:00:11:00:11, spoof checking on
9: eth10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP 
mode DORMANT qlen 1000
     link/ether 00:1b:21:55:1d:01 brd ff:ff:ff:ff:ff:ff
     vf 0 MAC 00:10:00:10:00:10, spoof checking on
