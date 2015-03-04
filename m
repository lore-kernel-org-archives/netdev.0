From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [PATCH net] af_unix: don't poll dead peers
Date: Wed, 4 Mar 2015 22:26:12 +0100
Message-ID: <CA+rthh_B-eZ6xjW+ZmcUuHjZy-Mw4v6NUPypWLn2W9nfjyOZ7Q@mail.gmail.com>
References: <1425499629-15223-1-git-send-email-minipli@googlemail.com>
	<1425500502.5130.232.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+rthh85wArTd9w7S_GhzbzMxrMRjWBym-4cEzc3MmkkUx+bsg@mail.gmail.com>
	<1425502952.5130.234.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:38434 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbbCDV0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 16:26:13 -0500
Received: by wiwh11 with SMTP id h11so34137570wiw.3
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 13:26:12 -0800 (PST)
In-Reply-To: <1425502952.5130.234.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Removed Rainer from the Cc list, his address is bouncing. ]

On 4 March 2015 at 22:02, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-03-04 at 21:39 +0100, Mathias Krause wrote:
>> On 4 March 2015 at 21:21, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >
>> > Using locks in _poll() is going to be tremendously expensive for some
>> > applications still using poll() or select() ?
>>
>> I've no idea but we're already taking this very lock in the
>> unix_peer_get() call a few lines above.
>
> This is not the same lock.
>
> other != sk

True. So, do you propose to not take the lock at all?
