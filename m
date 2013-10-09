From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2013-10-09
Date: Wed, 09 Oct 2013 13:56:52 -0400 (EDT)
Message-ID: <20131009.135652.2086284751199593695.davem@davemloft.net>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669Ab3JIR4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 13:56:55 -0400
In-Reply-To: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Wed,  9 Oct 2013 14:40:02 +0200

> Hello David,
> 
> this is a set of changes intended for net-next/linux-3.13.
> 
> As introduced one year ago (http://article.gmane.org/gmane.org.freifunk.batman/8484)
> in the last period we have been busy working on giving our batman-adv
> protocol/packet-format all those means to get stable and avoid incompatibilities
> in the near future (this is also why we did not send many changes for
> linux-3.12..).
> 
> With this patchset we are finally switching to a new compatibility version and
> within this development cycle I will send you all those changes aimed to
> introduce all the needed mechanism to avoid any further compatibility breakage.
> 
> First of all, in this batch you have the new TVLV code (Type Version Value
> Length) which is the first very important milestone towards our goal[1].
> With this mechanism we will be able to improve/change the packet contents layout
> (used by the various features) without breaking compatibility with older
> protocol versions anymore.
> The development of this new component has been started by Spyros Gasteratos
> during his Google Summer of Code 2012 and then adjusted, finished and submitted
> by Marek Lindner.
> 
> Together with it, you have a set of improvements that we are allowed to apply
> thanks to the switching to the new compat version.
> These changes are:
> - adapt the existing features to make them use the new TVLV mechanism
> - move from CRC16 to CRC32c for table correctness check in the TT component
> - reorder some of the flags sent over the wire
> - remove the __packed attribute from the OGM packet struct.
> 
> Moreover, with this patchset we are totally removing our VISualisation component
> that is now implemented in userspace.
> 
> Please pull let me know of any problem.

Pulled, thanks.
