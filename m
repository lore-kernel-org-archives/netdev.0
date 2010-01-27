From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: Re: [PATCH 1/1 V4] net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC
 driver
Date: Wed, 27 Jan 2010 12:01:45 +0100
Message-ID: <4B601D19.9050908@gaisler.com>
References: <1264417272-3800-1-git-send-email-kristoffer@gaisler.com>	<1264417272-3800-2-git-send-email-kristoffer@gaisler.com> <20100125083131.568abc34@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail176c2.megamailservers.com ([69.49.111.76]:43189 "EHLO
	mail176c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753679Ab0A0LFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 06:05:34 -0500
In-Reply-To: <20100125083131.568abc34@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Stephen Hemminger wrote:
> On Mon, 25 Jan 2010 12:01:12 +0100
> Kristoffer Glembo <kristoffer@gaisler.com> wrote:
> 
>> +/* Accept MAC address of the form macaddr=0x08,0x00,0x20,0x30,0x40,0x50 */
>> +static int macaddr[6];
>> +module_param_array(macaddr, int, NULL, 0);
>> +MODULE_PARM_DESC(macaddr, "GRETH Ethernet MAC address");
> 
> Don't you want an array of uchar here not int?
> 

I copied this approach from the sunhme driver and it works fine. Any special
reason to change it?

I have incorporated the rest of your feedback including ethtool support. 

Thanks a lot for the review!

Best regards,
Kristoffer Glembo
