From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: bridge vlan filtering question
Date: Tue, 26 Nov 2013 11:46:58 +0200
Message-ID: <CAF1J0HONLgBGdQFvD1A+r9yfD3fb2tr+beY6OzPe36tBhk0y_Q@mail.gmail.com>
References: <CAF1J0HPkZgiLCY2eiUUWb+t8dJSr2SrUsPtCeHPOxRqU9G6TbA@mail.gmail.com>
	<529394BC.5060805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:61380 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754808Ab3KZJq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 04:46:59 -0500
Received: by mail-oa0-f49.google.com with SMTP id i4so5674296oah.22
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 01:46:58 -0800 (PST)
In-Reply-To: <529394BC.5060805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 25, 2013 at 8:19 PM, Vlad Yasevich <vyasevich@gmail.com> wrote:
> On 11/25/2013 02:54 AM, Mike Rapoport wrote:
>> Hi all,
>>
>> I'm trying to use brigde vlan filtering and I cannot get any traffic
>> through the bridge.
>> After looking at the code I've noticed that br_get_pvid is always
>> returning VLAN_N_VID because VLAN_TAG_PRESENT is never set in the pvid
>> field of net_port_vlans.
>> Am I missing something or is this an actual bug?
>>
>
> It's a bug.  It's been fixed upstream and has been queued to stable.

Thanks a lot.

> commit d1c6c708c4da9d104e0b7c116654cb449bff9b5f
> Author: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Date:   Wed Oct 16 17:07:15 2013 +0900
>
>     bridge: Fix the way the PVID is referenced
>
>
> -vlad



-- 
Sincerely yours,
Mike.
