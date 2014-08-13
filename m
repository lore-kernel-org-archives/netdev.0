From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH] net: smsc911x: handle suspend/resume for mii bus
Date: Wed, 13 Aug 2014 22:14:32 +0200
Message-ID: <53EBC728.4000602@gmail.com>
References: <1407960197-5342-1-git-send-email-zonque@gmail.com> <CAOMZO5CJ+FejN38Kn-=iKor5GzNHAA7bOdK-mMKJ+nqqBXqAXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	stable@vger.kernel.org
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:33556 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbaHMUOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 16:14:38 -0400
In-Reply-To: <CAOMZO5CJ+FejN38Kn-=iKor5GzNHAA7bOdK-mMKJ+nqqBXqAXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fabio,

On 08/13/2014 10:09 PM, Fabio Estevam wrote:
> On Wed, Aug 13, 2014 at 5:03 PM, Daniel Mack <zonque@gmail.com> wrote:
>> Since commit a71e3c37960c ("net: phy: Set the driver when registering
>> an MDIO bus device"), the ->driver pointers of all mii buses are set to
>> the parent device's driver. This means that smsc911x_{suspend,resume}
>> will be called for the MII bus at suspend time now, in addition to the
>> actual netdev suspend callbacks.
> 
> This commit has been reverted in mainline:
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/net/phy/mdio_bus.c?id=ce7991e8198b80eb6b4441b6f6114bea4a665d66
> 

Ah, same conclusion there, so all's good :)

Thanks for the pointer, and please drop my patch then.


Daniel
