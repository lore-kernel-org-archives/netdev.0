From: "Ihar 'Philips' Filipau" <filia@softhome.net>
Subject: net/packet/af_packet.c:{1057,1073}: flags vs. msg->flags
Date: Mon, 10 Nov 2003 12:10:46 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3FAF7236.7020209@softhome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: netdev.vger.kernel.org

Hi!

    [ I'm trying to cc: netdev - but they are not that welcome - and 
require subscription. I'm way too lazy (and my mail box is not that 
fast) to subscribe to send simple typo - if this is a case at all. ]

    [ kernel v2.6.0-test7 as found on lxr.linux.no, 2.4.{18,22} has the 
same - but line numbers are different. ]

    On line 1057 we have: "msg->msg_flags|=MSG_TRUNC;" to indicate that 
message was truncated.

    But on line 1073, where we make return status to user, we check 
against user suplied flags, but NOT msg->msg_flags.

    It looks like obvious typo.

-- 
Ihar 'Philips' Filipau  / with best regards from Saarbruecken.
--                                                           _ _ _
  "... and for $64000 question, could you get yourself       |_|*|_|
    vaguely familiar with the notion of on-topic posting?"   |_|_|*|
                                 -- Al Viro @ LKML           |*|*|*|
