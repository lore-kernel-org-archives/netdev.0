From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: move inline functions to the header file
Date: Tue, 07 Apr 2015 22:26:23 +0300
Message-ID: <55242F5F.2060409@cogentembedded.com>
References: <4254119.qJUdUQCUqs@wasted.cogentembedded.com> <20150407.152249.360575010614186977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:36199 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623AbbDGT00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 15:26:26 -0400
Received: by lagv1 with SMTP id v1so49992496lag.3
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 12:26:25 -0700 (PDT)
In-Reply-To: <20150407.152249.360575010614186977.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/07/2015 10:22 PM, David Miller wrote:

>> The explicitly inline functions belong to the header files, so move
>> cpu_to_edmac() and edmac_to_cpu() into the driver header.

>> While at it, make these functions return 'u32' instead of '__u32'.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> Then... ummm... remove the inline keyword?

> If it's not used anywhere else, that's the thing to do.

    Results in more code, as I noted in the patch posting that you skipped 
when replying. At least with gcc 4.7.

WBR, Sergei
