From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Netlink mmap tx security?
Date: Thu, 16 Oct 2014 01:45:22 +0200
Message-ID: <543F0712.8080503@redhat.com>
References: <CALCETrUYBed_TBacxoDPMphM5y=iqxho2isrDruOQi=pmK2yoQ@mail.gmail.com> <20141014.160056.2113064815910782529.davem@davemloft.net> <CALCETrWDSG2EhxBnM8Jm55Ov8PYQ_w3Wf88SKYOB1q1WgRpbEw@mail.gmail.com> <20141014.220111.179628329028952302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, torvalds@linux-foundation.org,
	kaber@trash.net, netdev@vger.kernel.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54326 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751273AbaJOXp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 19:45:56 -0400
In-Reply-To: <20141014.220111.179628329028952302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/2014 04:01 AM, David Miller wrote:
> From: Andy Lutomirski <luto@amacapital.net>
> Date: Tue, 14 Oct 2014 15:16:46 -0700
>
>> It's at least remotely possible that there's something that assumes
>> that assumes that the availability of NETLINK_RX_RING implies
>> NETLINK_TX_RING, which would be unfortunate.
>
> I already found one such case, nlmon :-/

Hmm, can you elaborate? I currently don't think that nlmon cares
actually.
