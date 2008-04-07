From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 10375] New: IPSec tunnel kernel panic
Date: Mon, 7 Apr 2008 06:37:53 +0000
Message-ID: <20080407063753.GA4172@ff.dom.local>
References: <20080401120646.9b2f3b6a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	yuri@itinteg.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:40142 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbYDGGfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 02:35:33 -0400
Received: by ug-out-1314.google.com with SMTP id z38so419036ugc.16
        for <netdev@vger.kernel.org>; Sun, 06 Apr 2008 23:35:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080401120646.9b2f3b6a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01-04-2008 20:06, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue,  1 Apr 2008 11:44:10 -0700 (PDT)
> bugme-daemon@bugzilla.kernel.org wrote:
...
>> http://bugzilla.kernel.org/show_bug.cgi?id=10375
>> Steps to reproduce: Configured IPSec tunnel between two Linux with same kernel
>> versions. One of machines, connected via ADSL fall with kernel panic.
>>
>> 2.6.24.4:
>>
>> kernel BUG at include/linux/skbuff.h:948!
>> invalid opcode: 0000 [#1] SMP
>> Modules linked in: esp4 ah4 xfrm4_mode_tunnel ppp_synctty ppp_async
...
>> Pid: 2867, comm: pppoe Not tainted (2.6.24.4-1 #1)
>> EIP: 0060:[<dfb3d50b>] EFLAGS: 00010293 CPU: 0
>> EIP is at esp_input+0x3b2/0x3b6 [esp4]

Probably this new Thomas Graf's patch to esp_input() should help with
this problem:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=920fc941a9617f95ccb283037fe6f8a38d95bb69

Regards,
Jarek P.
