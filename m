From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: audit regression on x86 32-bit
Date: Sun, 13 Apr 2014 23:46:12 +0200
Message-ID: <534B05A4.7040507@redhat.com>
References: <20140413.150002.2000370566602899725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, torvalds@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43090 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750795AbaDMVqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2014 17:46:18 -0400
In-Reply-To: <20140413.150002.2000370566602899725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/13/2014 09:00 PM, David Miller wrote:
...
> Linus reported to me that Chrome stopped working on x86 32-bit for
> him, and he gets a bunch of audit errors in his log:
>
>    audit: type=1326 audit(1397359304.356:28108): auid=500 uid=500
> gid=500 ses=2 subj=unconfined_u:unconfined_r:chrome_sandbox_t:s0-s0:c0.c1023
> pid=3677 comm="chrome" exe="/opt/google/chrome/chrome" sig=0
> syscall=172 compat=0 ip=0xb2dd9852 code=0x30000
>
>    audit: type=1326 audit(1397359304.356:28109): auid=500 uid=500
> gid=500 ses=2 subj=unconfined_u:unconfined_r:chrome_sandbox_t:s0-s0:c0.c1023
> pid=3677 comm="chrome" exe="/opt/google/chrome/chrome" sig=0 syscall=5
> compat=0 ip=0xb2dd9852 code=0x50000
>
> He hasn't finished bisecting but it is starting to look like it's
> the BPF changes that went into this merge window.
>
> Daniel and Alexei can you guys look into this?

Yes, we will look into this asap. Thanks.
