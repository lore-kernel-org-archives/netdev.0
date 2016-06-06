From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: add address family checks to netlbl_{sock,
 req}_delattr()
Date: Mon, 06 Jun 2016 14:06:57 -0700 (PDT)
Message-ID: <20160606.140657.1714281987390130104.davem@davemloft.net>
References: <146524175890.8042.12012703565205416569.stgit@localhost>
	<CAGH-Kgsftoux6aaJg6c5WCX1sTSpaGoyDN_Y0Od+9Qh+87FD4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maninder1.s@samsung.com,
	selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbcFFVHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 17:07:01 -0400
In-Reply-To: <CAGH-Kgsftoux6aaJg6c5WCX1sTSpaGoyDN_Y0Od+9Qh+87FD4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Mon, 6 Jun 2016 15:37:56 -0400

> On Mon, Jun 6, 2016 at 3:35 PM, Paul Moore <pmoore@redhat.com> wrote:
>> From: Paul Moore <paul@paul-moore.com>
>>
>> It seems risky to always rely on the caller to ensure the socket's
>> address family is correct before passing it to the NetLabel kAPI,
>> especially since we see at least one LSM which didn't. Add address
>> family checks to the *_delattr() functions to help prevent future
>> problems.
>>
>> Cc: <stable@vger.kernel.org>
>> Reported-by: Maninder Singh <maninder1.s@samsung.com>
>> Signed-off-by: Paul Moore <paul@paul-moore.com>
>> ---
>>  net/netlabel/netlabel_kapi.c |   12 ++++++++++--
>>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> DaveM, since this is such a trivial fix I'm adding it into my
> selinux#next branch right now, but if you would prefer to carry it via
> netdev#next let me know.

That's fine.
