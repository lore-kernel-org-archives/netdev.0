From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: Call rcu_read_unlock() before copy_to_user()
Date: Thu, 22 Jan 2015 10:03:09 -0800
Message-ID: <CAADnVQJa5KNkLWeSwC6X_4WJ5bPS9Me+EZqqJSO77RCg4fHwWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:35332 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbbAVSDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 13:03:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2015 at 9:54 AM, Michael Holzheu
<holzheu@linux.vnet.ibm.com> wrote:
>> > So call rcu_read_unlock() before copy_to_user(). We can
>> > release the lock earlier because it is not needed for copy_to_user().
>>
>> we cannot move the rcu unlock this way, since it protects the value.
>> So we need to copy the value while still under rcu.
>
> Ok, right. I assume you will provide the correct fix.

sure :) will do.
