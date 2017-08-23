From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Wed, 23 Aug 2017 10:38:50 +0530
Message-ID: <CAA5aLPgA+YzavA8tw6uqfR8d6r058OymJOE+jevVmDA2Ar21rg@mail.gmail.com>
References: <CAA5aLPic9U4cwFJuTd4qBZrV=oVUSfmPzVRR_jXOBpJMU11b0A@mail.gmail.com>
 <CAA5aLPgekZJgsZV-MAD+F+ggUugQkz12D9Ef=kbP9Ev=Q1QsDw@mail.gmail.com>
 <1502879661.4936.98.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPh0m=ZZp5kcz9h3if8kemg0QRykBpfYAnr6Bd1ptoeKKg@mail.gmail.com>
 <1502969805.4936.154.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPjs2S0cV7MoYLB6MvZVKXomUmwpi=EVHDXh=AwR_xBqsw@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD005C7B1@AcuExch.aculab.com>
 <CAA5aLPhVSnJkGNtwEeswbPnhT_RdJewAKDs-pJOUzTPEpwkUAA@mail.gmail.com>
 <1503328678.2499.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPhtK8YbSDua-F16C0W9fLm2w4=ta4g+Tv+wsUEqYPCxUg@mail.gmail.com>
 <1503337453.2499.7.camel@edumazet-glaptop3.roam.corp.google.com>
 <1503337498.2499.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPgtfrA053gAbsXOZTdrJKtsOZODUmF5cPGmnOmsO3PbOA@mail.gmail.com> <CADVnQy=57_rc8A93zAcqr9hz1WtWniSoZdtx+-aTiZ6AyjZmQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33815 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751140AbdHWFIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 01:08:51 -0400
Received: by mail-pg0-f50.google.com with SMTP id s14so3285079pgs.1
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 22:08:51 -0700 (PDT)
In-Reply-To: <CADVnQy=57_rc8A93zAcqr9hz1WtWniSoZdtx+-aTiZ6AyjZmQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 5:58 PM, Neal Cardwell <ncardwell@google.com> wrote:
> On Tue, Aug 22, 2017 at 1:42 AM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
>> There are multiple hosts/clients. All are mainly windows based.
>>
>> Timestamp is not used as my clients mainly are windows based and in
>> that it tcp timestamp is by defauly disabled.
> ...
>> net.ipv4.tcp_tw_reuse=1
>> net.ipv4.tcp_tw_recycle=1
>
> I suspect the problem is there. The net.ipv4.tcp_tw_recycle setting
> should be 0. Running with the value 1 is known to cause buggy behavior
> related to TCP timestamps, and that feature has been removed in kernel
> v4.12.
>
> Can you please re-run your tests with net.ipv4.tcp_tw_recycle=0 or a
> newer kernel?
>
> neal

Thanks for your reply.

I understand that.

But my point is, though tcp timestamp is enabled on the server, but as
client is not using it ... so how come this _bug_ (if any) is
triggered in first place.
