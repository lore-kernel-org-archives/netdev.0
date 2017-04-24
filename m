From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH iproute2 net 3/8] tc/pedit: Introduce 'add' operation
Date: Mon, 24 Apr 2017 14:04:40 +0300
Message-ID: <CAJ3xEMjwZV5Ky_XEmmY7O0yHFtMDTFJnF+L94Zmb2D5iWi++tw@mail.gmail.com>
References: <20170423125356.1298-1-amir@vadai.me> <20170423125356.1298-4-amir@vadai.me>
 <f358025b-2618-3f22-b593-2e4e70fb7a79@mojatatu.com> <20170424075203.GA3265@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35400 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1168989AbdDXLEn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 07:04:43 -0400
Received: by mail-io0-f174.google.com with SMTP id r16so181926486ioi.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 04:04:43 -0700 (PDT)
In-Reply-To: <20170424075203.GA3265@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 10:52 AM, Amir Vadai <amir@vadai.me> wrote:
> On Sun, Apr 23, 2017 at 01:44:51PM -0400, Jamal Hadi Salim wrote:
>> Thanks for the excellent work.

sure, it's Amir, you know..

>> On 17-04-23 08:53 AM, Amir Vadai wrote:

>> Mostly curious about hardware handling.

> As to hardware handling, Or did the implementation so he will answer
> better. AFAIK, current implementation doesn't allow partial field
> setting/adding, so such a rule can't be offloaded. I think it is only to
> make things simple and because there was no use case for that.
> To my knowledge, hardware should support such thing if needed.

yeah (currently no partial setting) and yeah (in the future yes, will
support partial setting of offset into
field and partial length to set from there) and no for partial addition.

The reason we decided to disallow partial addition in the FW API was
what do you do with the carry, e.g you
add a value to the 2nd nibble of IP address and there are carry bits,
where do you take them? this becomes
even more ugly if you are dealing with mac addresses. I guess once
there's use case for partial add offload,
we will revisit that.

Or.
