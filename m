From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [net-2.6.24][patch 2/2] Dynamically allocate the loopback device
Date: Wed, 26 Sep 2007 15:40:25 -0600
Message-ID: <m1d4w5t8ae.fsf@ebiederm.dsl.xmission.com>
References: <224b7d320709171212o66734847kbd17efa817b482fc@mail.gmail.com>
	<20070917.185349.98863851.davem@davemloft.net>
	<m1r6kwpu9t.fsf@ebiederm.dsl.xmission.com>
	<20070925.192406.18290033.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pjwaskiewicz@gmail.com, dlezcano@fr.ibm.com,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.osdl.org, benjamin.thery@bull.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:56634 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758062AbXIZVlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 17:41:35 -0400
In-Reply-To: <20070925.192406.18290033.davem@davemloft.net> (David Miller's
	message of "Tue, 25 Sep 2007 19:24:06 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> I've put these patches into the just-rebased net-2.6.24 tree.
>
> I made a minor modification to the second patch, the
> out_free_netdev: code in loopback_init() ended like this:
>
> out_free_netdev:
> 	free_netdev(dev);
> 	goto out;
> 	return err;
> };
>
> I got rid of the spurious return statement and the trailing
> semi-colon after the function closing brace.

Thanks.  I feel silly for not doing a closer code review of
this variant of the patch and missing this bug.

Eric
