From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: circular locking dependency splat due to f9eb8aea2a1e
Date: Wed, 8 Jun 2016 14:59:22 -0600
Message-ID: <6f4b437a-077a-d152-df1b-ecf6da24ff71@cumulusnetworks.com>
References: <471b265b-d938-fd3c-7de6-91cc232b4e2b@cumulusnetworks.com>
 <CANn89iLquP-_fsFrSOUqxtg3YCYNuXgqO+TCYMcxc8foChB8jA@mail.gmail.com>
 <70835825-c395-7a1a-90e1-fb0e3542adbf@cumulusnetworks.com>
 <CANn89iK-nrvyZj7F1nt8aRKBEzt+SXVV8HOAxrDak1B3UcjC2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36266 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161792AbcFHU7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 16:59:14 -0400
Received: by mail-pf0-f179.google.com with SMTP id t190so5970865pfb.3
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 13:59:14 -0700 (PDT)
In-Reply-To: <CANn89iK-nrvyZj7F1nt8aRKBEzt+SXVV8HOAxrDak1B3UcjC2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/16 2:32 PM, Eric Dumazet wrote:
> On Wed, Jun 8, 2016 at 1:31 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> On 6/8/16 2:30 PM, Eric Dumazet wrote:
>>>
>>>
>>> It looks VRF was already lacking annotation for busylock then ?
>>
>>
>> I sent a patch adding IFF_NO_QUEUE flag
>>
>
> OK, but we still need the fix, in case a qdisc is installed on vrf
> (who knows...)

Sure. What about other virtual devices? e.g., I can generate the same 
splat with ipvlan.
