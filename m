From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH] fjes: Do not load fjes driver if system does not have
 extended socket device.
Date: Wed, 8 Mar 2017 14:15:21 -0500
Message-ID: <fa1574c9-9f41-459e-d19b-9db9d9201d64@gmail.com>
References: <fb537059-35b3-3dce-23fb-9a59e8f6926a@gmail.com>
 <20170307.134440.1909011889217005504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34536 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753795AbdCHTnb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 14:43:31 -0500
Received: by mail-qk0-f193.google.com with SMTP id v125so14088620qkh.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 11:43:10 -0800 (PST)
In-Reply-To: <20170307.134440.1909011889217005504.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 03/07/2017 04:44 PM, David Miller wrote:
> From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
> Date: Thu, 2 Mar 2017 11:56:44 -0500
>
>> +
>>  /* fjes_init_module - Driver Registration Routine */
>>  static int __init fjes_init_module(void)
>>  {
>>  	int result;
>> +	bool found = false;
>> +
>
> Please order local variable declarations from longest to shortest
> line.

Thank you for your review.
I'll update it soon.

Thanks,
Yasuaki Ishimatsu

> Thanks.
>
