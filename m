From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH RFC net-next 0/4] bridge: improve cache utilization
Date: Tue, 31 Jan 2017 19:09:09 +0100
Message-ID: <2c59b56a-4a8b-0f32-31d1-1e8c44643958@cumulusnetworks.com>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
 <20170131083919.51a3ac9f@xeon-e3>
 <31c4c454-b0e5-5a84-ffce-c8b39fa2d301@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:33306 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751353AbdAaSJM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:09:12 -0500
Received: by mail-wm0-f45.google.com with SMTP id t18so21782943wmt.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:09:11 -0800 (PST)
In-Reply-To: <31c4c454-b0e5-5a84-ffce-c8b39fa2d301@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/01/17 17:41, Nikolay Aleksandrov wrote:
>>
>> I agree with the first 3 patches, but not the last one.
>> Changing the API just for a performance hack is not necessary. Instead make
>> the algorithm smarter and use per-cpu values.
>>
> 
> Thanks for the feedback, I would very much prefer any of the other two approaches
> I tried (per-cpu pool and per-cpu for each fdb), from the two the second one -
> per-cpu for each fdb is much simpler, so would it be acceptable to do per-cpu allocation
> for each fdb ?
> 
> 
> 

Okay, after some more testing the version with per-cpu per-fdb allocations, at 300 000 fdb entries
I got 120 failed per-cpu allocs which seems okay. I'll wait a little more and will repost the series
with per-cpu allocations and without the RFC tag.

Thanks,
 Nik
