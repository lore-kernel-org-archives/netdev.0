From: Amit Kucheria <amitk@ittc.ku.edu>
Subject: Initializing sk_buff_head
Date: Wed, 17 Apr 2002 13:16:44 -0500 (CDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0204171314230.13652-100000@havoc.ittc.ku.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Referring to Alan Cox's article on "Network buffers and memory mangement",
he seems to be the only person who has ever mentioned something about
skb_queue_head_init() in some lines. (found out by lots of googling).

It seems previously there was a member in the 'device' struct called
'buffs' which essentially acted as queues for packets with different
kernel priorities.

What is the current equivalent feature now (2.2 & 2.4)? More specifically,
do i need to initialize a sk_buff_head for every "software-only" device
that I create? And which routines directly act on these queues?

TIA
Regards,
Amit

-- 
I'm an angel!!! Honest!
The horns are just there to hold the halo up straight.
^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^
                  Amit Kucheria
          EECS Grad. Research Assistant
         University of Kansas @ Lawrence
   (R)+1-(785)-830 8521 ||| (O)+1-(785)-864 7774
____________________________________________________

