From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETLINK]: Fix nla_parse_nested_compat() to call nla_parse()
 directly
Date: Thu, 22 May 2008 14:45:23 +0200
Message-ID: <48356AE3.7050700@trash.net>
References: <20080521214523.GB22591@codemonkey.org.uk> <20080521151021.3d47a3d8@extreme> <20080522002155.GP20815@postel.suug.ch> <20080522113720.GR20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Stephen Hemminger <shemminger@vyatta.com>,
	Dave Jones <davej@codemonkey.org.uk>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36668 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760653AbYEVMrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 08:47:04 -0400
In-Reply-To: <20080522113720.GR20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> The purpose of nla_parse_nested_compat() is to parse attributes
> which contain a struct followed by a stream of nested attributes.
> So far, it called nla_parse_nested() to parse the stream of
> nested attributes which was wrong, as nla_parse_nested() expects
> a container attribute as data which holds the attribute stream.
> It needs to call nla_parse() directly while pointing at the
> next possible alignment point after the struct in the beginning
> of the attribute.
>
> With this patch, I can no longer reproduce the reported leftover
> warnings.
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Looks good to me, thanks for fixing this Thomas.

