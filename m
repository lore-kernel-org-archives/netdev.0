From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH] xfrm: make xfrm_algo.c a module
Date: Tue, 15 May 2012 12:28:48 +0100
Message-ID: <4FB25A100200007800083C70@nat28.tlf.novell.com>
References: <4FAA3EAF02000078000826E4@nat28.tlf.novell.com>
 <20120514.183721.1989442389245940694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:56462 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757153Ab2EOL2U convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:2:2>);
	Tue, 15 May 2012 07:28:20 -0400
In-Reply-To: <20120514.183721.1989442389245940694.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 15.05.12 at 00:37, David Miller <davem@davemloft.net> wrote:
> From: "Jan Beulich" <JBeulich@suse.com>
> Date: Wed, 09 May 2012 08:53:51 +0100
> 
>> By making this a standalone config option (selected as needed),
>> selecting CRYPTO from here rather than from XFRM (which is boolean)
>> allows the core crypto code to become a module again even when XFRM=y.
>> 
>> Signed-off-by: Jan Beulich <jbeulich@suse.com>
>  ...
>> @@ -15,9 +15,6 @@
>>  #include <linux/crypto.h>
>>  #include <linux/scatterlist.h>
>>  #include <net/xfrm.h>
>> -#if defined(CONFIG_INET_AH) || defined(CONFIG_INET_AH_MODULE) || 
> defined(CONFIG_INET6_AH) || defined(CONFIG_INET6_AH_MODULE)
>> -#include <net/ah.h>
>> -#endif
> 
> This is completely unrelated to the change you are trying to make in
> this patch.
> 
> It belongs in a separate change.

I apologize for that, I meant to split this out and then forgot. I'll
re-submit the two things separately.

Jan
