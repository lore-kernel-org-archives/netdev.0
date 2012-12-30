From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] team: add ethtool support
Date: Sat, 29 Dec 2012 17:35:30 -0800 (PST)
Message-ID: <20121229.173530.463452112273354773.davem@davemloft.net>
References: <1356830366-991-1-git-send-email-fbl@redhat.com>
	<20121229172945.25a09fc8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fbl@redhat.com, netdev@vger.kernel.org, jiri@resnulli.us
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610Ab2L3Bfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 20:35:33 -0500
In-Reply-To: <20121229172945.25a09fc8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 29 Dec 2012 17:29:45 -0800

> On Sat, 29 Dec 2012 23:19:26 -0200
> Flavio Leitner <fbl@redhat.com> wrote:
> 
>> This patch adds few ethtool operations to team driver.
>> 
>> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> 
> What is the motivation for this? Is there an application that depends
> on ethtool (versus netlink, or /proc)?
> 
> Sorry, I see no point in providing ethtool statistics for generic data that is already
> reported by existing netlink and other infrastructure. The purpose of ethtool
> statistics is to report device specific that is not available through the normal
> generic statistics.

Agreed, ethtool stats should _ONLY_ report device specific
statistics.
