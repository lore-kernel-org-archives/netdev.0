From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware forwarded
 packets
Date: Sun, 22 Mar 2015 20:33:27 -0700
Message-ID: <550F8987.5070600@roeck-us.net>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com> <20150320.163655.474336751434677390.davem@davemloft.net> <550C92F3.50302@cumulusnetworks.com> <20150320220946.GB31769@lunn.ch> <20150323002215.GA6074@roeck-us.net> <550F6D7D.7030403@gmail.com> <550F8102.7040701@roeck-us.net> <550F8600.2020300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, roopa <roopa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>, sfeldma@gmail.com,
	jiri@resnulli.us, ronen.arad@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:57206 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbbCWDda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 23:33:30 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YZt7J-001cZy-LP
	for netdev@vger.kernel.org; Mon, 23 Mar 2015 03:33:30 +0000
In-Reply-To: <550F8600.2020300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/2015 08:18 PM, John Fastabend wrote:
[ ... ]
>
> Sorry I probably wasn't being clear. I'm just saying we don't need to
> have the driver tell us if the packet has been forwarded. All we have
> to do in software is the switch check and assume all packets sent to us
> from the driver have already been handled by the hardware. Roopa is
> working on this I believe.
>

Ah, ok. Yes, you are correct. Sorry, I missed that.

Thanks,
Guenter
