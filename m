From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH] fjes: Move fjes driver info message into fjes_acpi_add()
Date: Wed, 22 Feb 2017 16:37:10 -0500
Message-ID: <c01f5a56-d1ad-347a-573a-bd07764ffc52@gmail.com>
References: <210dfe59-18a0-4678-0a63-6751f21f0eb5@gmail.com>
 <20170222.154501.1301489476392840185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33403 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933406AbdBVVpc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 16:45:32 -0500
Received: by mail-qt0-f196.google.com with SMTP id n13so2163347qtc.0
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 13:45:31 -0800 (PST)
In-Reply-To: <20170222.154501.1301489476392840185.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for quick response.
I'll think of other solution.

Thanks,
Yasuaki Ishimatsu

On 02/22/2017 03:45 PM, David Miller wrote:
> From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
> Date: Wed, 22 Feb 2017 15:40:49 -0500
>
>> To avoid the confusion, the patch moves the message into
>> fjes_acpi_add() so that it is shows only when fjes_acpi_add()
>> succeeded.
>
> This change means it'll never be printed for platform driver matches,
> which is even worse than what we have now.
>
