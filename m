From: Adam Nielsen <a.nielsen@shikadi.net>
Subject: Re: Why do programs freeze with big network transfers?
Date: Fri, 31 Dec 2010 11:20:56 +1000
Message-ID: <4D1D2FF8.2070806@shikadi.net>
References: <ifhc54$efg$1@dough.gmane.org> <1293695919.7150.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293695919.7150.18.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> After a few seconds of data going over the network, X-Windows freezes.  No
>> screen updates, the mouse cursor won't move, for all intents and purposes the
>> system has frozen solid.  I'm playing music with XMMS2 and that keeps going,
>> but occasionally even that stops too.  After a minute (between 45 and 65
>> seconds) everything unfreezes and keeps going as per normal.  Less than 10
>> seconds later everything freezes again for another minute!  This keeps going
>> until the file transfer has finished.
>
> This rings a bell here, could you try to apply commit
>
> 482964e56e1320cb7952faa1932d8ecf59c4bf75
> (net: Fix the condition passed to sk_wait_event())
>
> This commit was included in 2.6.36, so you could also try 2.6.36.2
> kernel.

Just booted into 2.6.36.2 and it looks like the problem has indeed been fixed! 
  I've been able to perform the same transfer that would previously cause a 
freeze 100% of the time and it went through fine.

Many thanks for your help!

Cheers,
Adam.
