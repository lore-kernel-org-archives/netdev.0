From: Eric Dumazet <edumazet@google.com>
Subject: Re: circular locking dependency splat due to f9eb8aea2a1e
Date: Wed, 8 Jun 2016 13:32:57 -0700
Message-ID: <CANn89iK-nrvyZj7F1nt8aRKBEzt+SXVV8HOAxrDak1B3UcjC2A@mail.gmail.com>
References: <471b265b-d938-fd3c-7de6-91cc232b4e2b@cumulusnetworks.com>
 <CANn89iLquP-_fsFrSOUqxtg3YCYNuXgqO+TCYMcxc8foChB8jA@mail.gmail.com> <70835825-c395-7a1a-90e1-fb0e3542adbf@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:33000 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161702AbcFHUc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 16:32:58 -0400
Received: by mail-yw0-f182.google.com with SMTP id g20so18998728ywb.0
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 13:32:58 -0700 (PDT)
In-Reply-To: <70835825-c395-7a1a-90e1-fb0e3542adbf@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 8, 2016 at 1:31 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 6/8/16 2:30 PM, Eric Dumazet wrote:
>>
>>
>> It looks VRF was already lacking annotation for busylock then ?
>
>
> I sent a patch adding IFF_NO_QUEUE flag
>

OK, but we still need the fix, in case a qdisc is installed on vrf
(who knows...)

I will submit it formally.
