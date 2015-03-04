From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] af_unix: don't poll dead peers
Date: Wed, 04 Mar 2015 13:02:32 -0800
Message-ID: <1425502952.5130.234.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425499629-15223-1-git-send-email-minipli@googlemail.com>
	 <1425500502.5130.232.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+rthh85wArTd9w7S_GhzbzMxrMRjWBym-4cEzc3MmkkUx+bsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Olivier Mauras <olivier@mauras.ch>,
	Rainer Weikusat <rweikusat@mssgmbh.com>,
	PaX Team <pageexec@freemail.hu>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35568 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbbCDVCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 16:02:34 -0500
Received: by igqa13 with SMTP id a13so40113063igq.0
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 13:02:34 -0800 (PST)
In-Reply-To: <CA+rthh85wArTd9w7S_GhzbzMxrMRjWBym-4cEzc3MmkkUx+bsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-04 at 21:39 +0100, Mathias Krause wrote:
> On 4 March 2015 at 21:21, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Using locks in _poll() is going to be tremendously expensive for some
> > applications still using poll() or select() ?
> 
> I've no idea but we're already taking this very lock in the
> unix_peer_get() call a few lines above.

This is not the same lock.

other != sk
