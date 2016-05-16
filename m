From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip link: Add support for kernel side filtering
Date: Mon, 16 May 2016 12:27:25 -0600
Message-ID: <7fb315f5-43c7-bcf1-f317-dab0a352f206@cumulusnetworks.com>
References: <1462974718-12860-1-git-send-email-dsa@cumulusnetworks.com>
 <20160516111931.1aaac4f3@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36590 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbcEPS12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:27:28 -0400
Received: by mail-io0-f180.google.com with SMTP id i75so215261166ioa.3
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 11:27:28 -0700 (PDT)
In-Reply-To: <20160516111931.1aaac4f3@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/16/16 12:19 PM, Stephen Hemminger wrote:
> On Wed, 11 May 2016 06:51:58 -0700
> David Ahern <dsa@cumulusnetworks.com> wrote:
>
>> Kernel gained support for filtering link dumps with commit dc599f76c22b
>> ("net: Add support for filtering link dump by master device and kind").
>> Add support to ip link command. If a user passes master device or
>> kind to ip link command they are added to the link dump request message.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> ---
>>  include/libnetlink.h |  6 ++++++
>>  ip/ipaddress.c       | 33 ++++++++++++++++++++++++++++++++-
>>  lib/libnetlink.c     | 28 ++++++++++++++++++++++++++++
>>  3 files changed, 66 insertions(+), 1 deletion(-)
>>
>
> Was this tested on older kernels?  Don't want to add something that breaks
> when run on old kernels that are in stable distros.
>

Yes. Not really far back but older 4.x kernels.

In general older kernels do not parse the attributes appended to the get 
request. This is very similar to the neigh filter added by 
b8c753245bad3f13a03b105b724ff406d278c753.
