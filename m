From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] test_bpf: fix sparse warnings
Date: Thu, 14 May 2015 20:17:19 +0200
Message-ID: <5554E6AF.1050103@iogearbox.net>
References: <1431574839-7099-1-git-send-email-ast@plumgrid.com> <5554C8F7.5080002@iogearbox.net> <5554D8E4.50500@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52923 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786AbbENSR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 14:17:26 -0400
In-Reply-To: <5554D8E4.50500@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/14/2015 07:18 PM, Alexei Starovoitov wrote:
...
> 0xffff0000ffffffffLL is unsigned. GCC does the right thing. Here
> we're just shutting up sparse.

Yep, that's clear; to not get any more reminders from Fengguang. ;)

> I actually most of the time use LL as well since it's one character
> shorter.

Ok, I see.
