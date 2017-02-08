From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Wed, 8 Feb 2017 06:18:02 -0800
Message-ID: <CACSApvYsn54hBZ7+vwM+TKjdBecTF9HLOj_LxXeb5vfF5EK8yA@mail.gmail.com>
References: <20170207140144.GA11233@localhost> <02874ECE860811409154E81DA85FBB5857D6DC87@ORSMSX115.amr.corp.intel.com>
 <CAF=yD-JLiABx6TcVg_8mS5ZhomRaZ+cZ8edx00hJNG8PDrsSjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Miroslav Lichvar <mlichvar@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>, Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:38466 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932148AbdBHOSn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 09:18:43 -0500
Received: by mail-it0-f50.google.com with SMTP id c7so103627569itd.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 06:18:43 -0800 (PST)
In-Reply-To: <CAF=yD-JLiABx6TcVg_8mS5ZhomRaZ+cZ8edx00hJNG8PDrsSjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2017 at 2:32 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
>>> 2) new SO_TIMESTAMPING option to receive from the error queue only
>>>    user data as was passed to sendmsg() instead of Ethernet frames
>>>
>>>    Parsing Ethernet and IP headers (especially IPv6 options) is not
>>>    fun and SOF_TIMESTAMPING_OPT_ID is not always practical, e.g. in
>>>    applications which process messages from the error queue
>>>    asynchronously and don't bind/connect their sockets.
>>
>> This would be useful for application writing.
>
> What kind of user data are you suggesting? Just a user-defined ID
> passed as a cmsg? Allowing such metadata to override
> skb_shinfo(skb)->tskey sounds fine.

Yes, exactly. Just a user-defined ID that overrides the
skb_shinfo(skb)->tskey.

Thanks,
Soheil
