From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] rhashtable: Do not lower max_elems when max_size
 is zero
Date: Fri, 28 Apr 2017 08:42:12 -0700
Message-ID: <c076bb39-a523-ffd1-2fa9-e942f654cc5e@gmail.com>
References: <56843a86-9a09-16e8-acec-05a80396f282@gmail.com>
 <20170427223024.32657-1-f.fainelli@gmail.com>
 <20170428061048.GA6817@gondor.apana.org.au>
 <20170428.101449.1468521013732143831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, tgraf@suug.ch
To: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35052 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1426249AbdD1PmP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 11:42:15 -0400
Received: by mail-it0-f68.google.com with SMTP id 70so6093093ita.2
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 08:42:14 -0700 (PDT)
In-Reply-To: <20170428.101449.1468521013732143831.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/28/2017 07:14 AM, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 28 Apr 2017 14:10:48 +0800
> 
>> The commit 6d684e54690c ("rhashtable: Cap total number of entries
>> to 2^31") breaks rhashtable users that do not set max_size.  This
>> is because when max_size is zero max_elems is also incorrectly set
>> to zero instead of 2^31.
>>
>> This patch fixes it by only lowering max_elems when max_size is not
>> zero.
>>
>> Fixes: 6d684e54690c ("rhashtable: Cap total number of entries to 2^31")
>> Reported-by: Florian Fainelli <f.fainelli@gmail.com>
>> Reported-by: kernel test robot <fengguang.wu@intel.com>
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Tested-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks Herbert
-- 
Florian
