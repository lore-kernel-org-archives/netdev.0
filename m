From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: ethtool: git tree not updated to v3.18
Date: Thu, 02 Apr 2015 11:50:25 +0200
Message-ID: <551D10E1.2080304@iogearbox.net>
References: <20150401143006.000001f7@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, bwh@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48385 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703AbbDBJua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 05:50:30 -0400
In-Reply-To: <20150401143006.000001f7@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2015 11:30 PM, Jesse Brandeburg wrote:
> Hi Ben,
>
> When trying to check a bug just now I noticed that the master
> branch of
> git://git.kernel.org/pub/scm/network/ethtool/ethtool
>
> still points to the v3.16 tag.
>
> But kernel.org shows version 3.18 released.  I did some quick
> investigation and it looks like the v3.18 tag points to a dangling
> commit that is not on a branch.
>
> $ git log --graph --oneline v3.18 |head -n5
> * ba9a11a Release version 3.18.
> * 1e8811a Fix build with musl by using more common typedefs
> * 99bc878 bug fix: SFP Tx BIAS uses memory wrong offset
> * 4614098 Release version 3.16.
> * 14ef76c test-cmdline: Disable test cases for --rxfh hash key parsing
>
> $ git log --graph --oneline origin/master |head -n5
> * 4614098 Release version 3.16.
> * 14ef76c test-cmdline: Disable test cases for --rxfh hash key parsing
> * 86c0326 ethtool: Support for configurable RSS hash key
> * e633626 ethtool-copy.h: sync with net
> * 05b8ad5 Release version 3.14.
>
> Maybe you can merge the commits from your working branch back onto
> master and make another 3.18.1 tag or something.
>
> I just did:
> git checkout master
> git merge v3.18
>
> which worked okay, I think.

Btw, are there any plans to keep track of ethtool patches in
netdev patchwork as well, like we do with iproute2?

I recall in early January this year there was a patch to add
qsfp diag information support to ethtool, but that probably
got lost on the list, not sure.

Cheers,
Daniel
