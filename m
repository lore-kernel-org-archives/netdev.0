From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Wed, 18 Feb 2015 06:05:08 -0800
Message-ID: <54E49C14.8010404@roeck-us.net>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <1424201196-4901-2-git-send-email-f.fainelli@gmail.com> <20150218011955.GA17155@lunn.ch> <54E40CC9.2000505@roeck-us.net> <CAGVrzcZNEz6+peBAaSfadFf+wf9p=8EJ0yqBVZqAmnfEaPDFPA@mail.gmail.com> <20150218134937.GI10224@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:37216 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbbBROG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 09:06:27 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YO5Gg-001H47-7e
	for netdev@vger.kernel.org; Wed, 18 Feb 2015 14:06:22 +0000
In-Reply-To: <20150218134937.GI10224@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2015 05:49 AM, Andrew Lunn wrote:
>> I have put a v2 here which addresses that by retaining which bridge
>> the port was added to and comparing that against the bridge net_device
>> we want to join:
>>
>> https://github.com/ffainelli/linux/tree/dsa-hw-bridge-v2
>
> Hi Florian
>
> This looks O.K.
>
> If we ever get a switch which does not allow disjoint sets of ports,
> it will need some changes, but lets not over engineer it now.
>

Good point. The driver for that chip would have to detect the situation,
maybe by storing the bridge mask, and reject to configure the port
if there is a bridge mask mismatch. So I think this could work with the
current API.

Guenter
