From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch net-next-2.6 1/4] rtnetlink: implement setting of master
 device
Date: Wed, 16 Feb 2011 16:25:19 +0100
Message-ID: <4D5BEC5F.9030803@trash.net>
References: <20110213193105.GD2740@psychotron.redhat.com> <20110216051844.53f577d5@s6510> <20110216143923.GB5727@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35348 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856Ab1BPPZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 10:25:22 -0500
In-Reply-To: <20110216143923.GB5727@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.02.2011 15:39, Jiri Pirko wrote:
> Wed, Feb 16, 2011 at 02:18:44PM CET, shemminger@vyatta.com wrote:
>> On Sun, 13 Feb 2011 20:31:06 +0100
>> Jiri Pirko <jpirko@redhat.com> wrote:
>>
>>> This patch allows userspace to enslave/release slave devices via netlink
>>> interface using IFLA_MASTER. This introduces generic way to add/remove
>>> underling devices.
>>>
>>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>
>> But, setting master means something different for each type of device?
> 
> Why isn't correct to use master also for bridge? It had no meaning there.

In fact the bridge netlink family uses IFLA_MASTER for exactly
the same purpose.
