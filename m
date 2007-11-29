From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv6 iptables]Interface group match
Date: Thu, 29 Nov 2007 18:15:27 +0100
Message-ID: <474EF3AF.3070201@trash.net>
References: <11955644701165-git-send-email-panther@balabit.hu> <1195564470928-git-send-email-panther@balabit.hu> <11955644702451-git-send-email-panther@balabit.hu> <11955644701536-git-send-email-panther@balabit.hu> <11955644702194-git-send-email-panther@balabit.hu> <20071123133933.GA31396@innominate.com> <474EB585.30407@balabit.hu> <474EE5C6.9070500@trash.net> <474EE79F.2000409@balabit.hu> <474EE86E.2010201@trash.net> <Pine.LNX.4.64.0711291813200.13075@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: panther@balabit.hu, Lutz Jaenicke <ljaenicke@innominate.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51176 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755644AbXK2RPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 12:15:37 -0500
In-Reply-To: <Pine.LNX.4.64.0711291813200.13075@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Nov 29 2007 17:27, Patrick McHardy wrote:
>>> The syntax "name/0xmask" is simply too strange for me.
>> Then how about name/name with masks also defined in rt_ifgroup?
>> The same question applies for marks of course.
>>
> I would find that confusing, which is why the new xt_TOS only
> allows names when no /mask or a mask of /allbits is used.

Its still useful, you don't have to use it :) Another alternative
would be to allow defining names to val/mask.
