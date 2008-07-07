From: Bill Nottingham <notting@redhat.com>
Subject: Re: [RFC PATCH 0/2] Allow full bridge configuration via sysfs
Date: Mon, 7 Jul 2008 16:53:42 -0400
Message-ID: <20080707205342.GA19710@nostromo.devel.redhat.com>
References: <cover.1215460681.git.notting@redhat.com> <4872819E.3040604@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753509AbYGGUzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 16:55:25 -0400
Content-Disposition: inline
In-Reply-To: <4872819E.3040604@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy (kaber@trash.net) said: 
> Bill Nottingham wrote:
>> Right now, you can configure most bridge device parameters via sysfs.
>> However, you cannot either:
>> - add or remove bridge interfaces
>> - add or remove physical interfaces from a bridge
>>
>> The attached patch set rectifies this. With this patch set, brctl
>> (theoretically) becomes completely optional, much like ifenslave is
>> now for bonding. (In fact, the idea for this patch, and the syntax
>> used herein, is inspired by the sysfs bonding configuration.)
>
> Both should use netlink instead of extending their sysfs interfaces.
> For bridging I have a patch for the bridge device itself, the API
> is so far missing support for adding ports though.

How does that improve the situation for bridge devices? Are all
bridging parameters (forward_delay, stp, etc.) going to be configurable
via netlink, or would we still then have multiple tools/interfaces
to configuration? Also, moving bonding configuration to netlink seems
like a step backwards.

Bill
