From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] forcedeth: jumbo frame support
Date: Sat, 16 Jul 2005 23:15:36 +0200
Message-ID: <42D978F8.7000107@colorfullife.com>
References: <42D94E95.1060303@colorfullife.com> <ea86ce22050716140987d7ef8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tim Mattox <tmattox@gmail.com>
In-Reply-To: <ea86ce22050716140987d7ef8@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tim Mattox wrote:

>This is just from a simple read of Manfred's patch, but shouldn't one side of
>the if-else use the NV_PKTLIMIT_2 value?
>
It should - and it's already fixed in the following patch for 0.37, 
which is already in Jeff's queue.
I didn't want to break the patch in Jeff's queue, thus I submitted the 
patch as it was.
It doesn't hurt much: 0.36 adds the jumbo frame support, 0.37 actually 
enables it.

--
    Manfred
