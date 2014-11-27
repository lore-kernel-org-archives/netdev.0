From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH RFC net-next] net: Add GRO support for GRE tunneling of
 TEB packets
Date: Thu, 27 Nov 2014 08:51:03 +0200
Message-ID: <CAJ3xEMgv=mqv0k+GRzrOjd5CwtpU-d+4M5BNtOak3VuxPvOUtQ@mail.gmail.com>
References: <1417014504-5929-1-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx_-TU+ktWY85bJ1gJOMZD1BOW5hbj=JdEHV5FohYxdjAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"H.K. Jerry Chu" <hkchu@google.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:46379 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbaK0GvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 01:51:05 -0500
Received: by mail-ob0-f182.google.com with SMTP id m8so3348876obr.27
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 22:51:03 -0800 (PST)
In-Reply-To: <CA+mtBx_-TU+ktWY85bJ1gJOMZD1BOW5hbj=JdEHV5FohYxdjAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2014 at 5:44 PM, Tom Herbert <therbert@google.com> wrote:
> On Wed, Nov 26, 2014 at 7:08 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> Add the missing parts in the gre gro handlers when the inner protocol
>> is ETH_P_TEB which is the case for OVS based GRE tunneling.

> I don't think this is the right approach. It would probably be better
> to a add a gro_receive handler for ETH_P_TEB and then you wouldn't
> need to modify GRE path with special case code. That would also be
> applicable in geneve.

Makes sense, I'll do that, thanks for the feedback.
