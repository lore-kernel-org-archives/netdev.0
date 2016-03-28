From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: fix a problem with
 netlbl_secattr_catmap_setrng()
Date: Mon, 28 Mar 2016 11:41:30 -0400 (EDT)
Message-ID: <20160328.114130.2069088439489149203.davem@davemloft.net>
References: <145917783800.9565.7759086668991534988.stgit@localhost>
	<CAHC9VhTV_0tdRgFEcRoF1qjBunjwK6rSp8wpB4Jqjow2ENToCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	Janak.Desai@gtri.gatech.edu, pmoore@redhat.com
To: paul@paul-moore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620AbcC1Plc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 11:41:32 -0400
In-Reply-To: <CAHC9VhTV_0tdRgFEcRoF1qjBunjwK6rSp8wpB4Jqjow2ENToCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>
Date: Mon, 28 Mar 2016 11:17:28 -0400

> On Mon, Mar 28, 2016 at 11:10 AM, Paul Moore <pmoore@redhat.com> wrote:
>> From: Janak Desai <Janak.Desai@gtri.gatech.edu>
>>
>> We try to be clever and set large chunks of the bitmap at once, when
>> possible; unfortunately we weren't very clever when we wrote the code
>> and messed up the if-conditional.  Fix this bug and restore proper
>> operation.
>>
>> Signed-off-by: Janak Desai <Janak.Desai@gtri.gatech.edu>
>> Signed-off-by: Paul Moore <paul@paul-moore.com>
>> ---
>>  net/netlabel/netlabel_kapi.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> DaveM, I'm planning on carrying this in selinux#next unless you really
> want to this to go to Linus via the netdev tree.

I'm fine with it going via your tree, thanks.
