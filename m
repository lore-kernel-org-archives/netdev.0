From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [clip] fix race between modifying entry->vccs and clip_start_xmit()
Date: Tue, 16 Sep 2003 06:59:56 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309161059.h8GAxtSa012211@ginger.cmf.nrl.navy.mil>
References: <mitch@sfgoth.com>
Cc: "David S. Miller" <davem@redhat.com>, romieu@fr.zoreil.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: Message from Mitchell Blank Jr <mitch@sfgoth.com>
   of "Mon, 15 Sep 2003 15:30:48 PDT." <20030915223048.GD92642@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030915223048.GD92642@gaz.sfgoth.com>,Mitchell Blank Jr writes:
>That should be the case at least for any VCC on a real interface[*].
>...
>[*] some protocols use psuedo-interfaces for their control connections - in
>    theory I guess they could be different but I don't believe there are
>    any cases where they are.  They wouldn't affect this issue anyways though.

afaict all vcc's are open/closed from user space including any control
vccs (often labelled ATM_VF_META).  this is a bit of a sore point with
some people who want to open atm sockets in the kernel.  if i remember
correctly the atm api explicitly states that you can sleep in atm_dev->close()
so it must be a user context.
