From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Thu, 15 Sep 2016 14:25:01 -0600
Message-ID: <cc67e1b1-ad0c-f0f6-4b4d-2eab80e940da@cumulusnetworks.com>
References: <20160913171950.GC32643@uranus>
 <8260ff1f-6907-aed8-caae-68d63a4ad529@cumulusnetworks.com>
 <20160915202219.GB1867@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34668 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753552AbcIOUZE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:25:04 -0400
Received: by mail-pf0-f175.google.com with SMTP id p64so19963496pfb.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:25:04 -0700 (PDT)
In-Reply-To: <20160915202219.GB1867@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/15/16 2:22 PM, Cyrill Gorcunov wrote:
>> ss -K is not working. Socket lookup fails to find a match due to a protocol mismatch.
>>
>> haven't had time to track down why there is a mismatch since the kill uses the socket returned
>> from the dump. Won't have time to come back to this until early next week.
> 
> Have you ran iproute2 patched? I just ran ss -K and all sockets get closed
> (including raw ones), which actually kicked me off the testing machine sshd :/

yes.
