From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH 0/2] Allow full bridge configuration via sysfs
Date: Mon, 07 Jul 2008 22:50:38 +0200
Message-ID: <4872819E.3040604@trash.net>
References: <cover.1215460681.git.notting@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bill Nottingham <notting@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38142 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755827AbYGGUul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 16:50:41 -0400
In-Reply-To: <cover.1215460681.git.notting@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Nottingham wrote:
> Right now, you can configure most bridge device parameters via sysfs.
> However, you cannot either:
> - add or remove bridge interfaces
> - add or remove physical interfaces from a bridge
> 
> The attached patch set rectifies this. With this patch set, brctl
> (theoretically) becomes completely optional, much like ifenslave is
> now for bonding. (In fact, the idea for this patch, and the syntax
> used herein, is inspired by the sysfs bonding configuration.)

Both should use netlink instead of extending their sysfs interfaces.
For bridging I have a patch for the bridge device itself, the API
is so far missing support for adding ports though.

