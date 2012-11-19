From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/10] batman-adv: export compatibility version via
 debugfs
Date: Mon, 19 Nov 2012 14:10:41 -0500 (EST)
Message-ID: <20121119.141041.1333512822842997190.davem@davemloft.net>
References: <1353313451-2930-1-git-send-email-ordex@autistici.org>
	<1353313451-2930-5-git-send-email-ordex@autistici.org>
	<1353351150.4156.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ordex@autistici.org, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org, lindner_marek@yahoo.de
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753966Ab2KSTKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 14:10:43 -0500
In-Reply-To: <1353351150.4156.4.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 19 Nov 2012 18:52:30 +0000

> On Mon, 2012-11-19 at 09:24 +0100, Antonio Quartulli wrote:
>> Different versions of the batman-adv module may use the same compatibility
>> version, but this is not understandable at runtime (the only way is to parse the
>> kernel log and fetch the batman-adv advertisement message on loading). The user
>> may want to know whether two nodes using different versions can communicate or
>> not. For this purpose the module has to export this value through debugfs.
> [...]
> 
> I do hope that you're not planning to use unstable debugfs interfaces
> indefinitely.

I think this is a huge mess and I don't think I'm going to pull this
series for that reason.

Once we allow you to merge your protocol/facility/whatever into the
main kernel tree, you have to be mindful of compatability in a very
real way.

These kinds of changes show that this isn't actually happening.

So the only weapon I have against you doing more foolishly
incompatable changes is to simply stop taking your submissions until
things are corrected.
