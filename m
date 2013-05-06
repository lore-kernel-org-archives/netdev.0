From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] 3c59x: fix PCI resource management
Date: Mon, 06 May 2013 23:33:52 +0400
Message-ID: <518805A0.7090309@cogentembedded.com>
References: <5187E884.7060101@cogentembedded.com> <20130506.135305.1659397370290340459.davem@davemloft.net> <5187F512.4070104@cogentembedded.com> <20130506.145937.821236821026536204.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:43666 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756022Ab3EFTdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 15:33:53 -0400
Received: by mail-lb0-f180.google.com with SMTP id v1so3737218lbd.39
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 12:33:51 -0700 (PDT)
In-Reply-To: <20130506.145937.821236821026536204.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2013 10:59 PM, David Miller wrote:

>
>>      How about I completely drop this change (and maybe deal with it in a
>>      subsequent cleanup patch)?
> Sure, that cleanup would have to wait until after the merge window is
> closed and I reopen net-next.

    Yes, I know.
    What's your opinion on getting rid of VORTEX_PCI() invocations in 
the PCI
remove() method done in this same patch -- are they worth splitting to a
cleanup patch too?..

> Thanks.

WBR, Sergei
