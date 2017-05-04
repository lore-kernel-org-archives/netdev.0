From: Jens Axboe <axboe@kernel.dk>
Subject: Re: WARNING: CPU: 2 PID: 682 at net/wireless/util.c:1236
Date: Thu, 4 May 2017 09:40:08 -0600
Message-ID: <b25325a9-ab93-1c57-3b59-2d52a76d279a@kernel.dk>
References: <240bae44-56e4-f342-0d1b-358a573e2eeb@kernel.dk>
 <20170504.112512.833061289089590605.davem@davemloft.net>
 <4ad7a627-62c7-be34-2dae-c54bb3ef0a15@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linuxwifi@intel.com,
        johannes.berg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:36698 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752221AbdEDPkL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 11:40:11 -0400
Received: by mail-it0-f46.google.com with SMTP id o5so274492ith.1
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 08:40:11 -0700 (PDT)
In-Reply-To: <4ad7a627-62c7-be34-2dae-c54bb3ef0a15@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2017 09:27 AM, Jens Axboe wrote:
> On 05/04/2017 09:25 AM, David Miller wrote:
>> From: Jens Axboe <axboe@kernel.dk>
>> Date: Thu, 4 May 2017 09:23:36 -0600
>>
>>> Running current -git on my laptop, and I see this spew every once
>>> in a while. This is new, haven't seen it in 4.11 or previously. Driver
>>> is iwlwifi:
>>
>> Please try:
>>
>> http://patchwork.ozlabs.org/patch/758364/
> 
> Will do, compiling...

Yep works, thanks.

-- 
Jens Axboe
