From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] sctp: Fix mangled IPv4 addresses on a IPv6 listening
 socket
Date: Wed, 27 May 2015 11:34:21 +0200
Message-ID: <55658F9D.6030404@iogearbox.net>
References: <20150526233017.GB22391@obsidianresearch.com> <063D6719AE5E284EB5DD2968C1650D6D1CB408FE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	'Jason Gunthorpe' <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52701 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbbE0Jef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 05:34:35 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB408FE@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2015 11:06 AM, David Laight wrote:
> From: Jason Gunthorpe
...
>> Fixes: 299ee123e198 (sctp: Fixup v4mapped behaviour to comply with Sock API)
> ...
>> This bugfix should be a candidate for -stable
>
> Anyone know off-hand which kernel releases are affected?
> I'm going to have to note this in the release notes for one of our products.

Ever heard of git-describe(1) ? ;)

git describe 299ee123e19889d511092347f5fc14db0f10e3a6
v3.16-rc7-1525-g299ee12
