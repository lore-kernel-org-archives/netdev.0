From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [2/3] via-rhine: de-isolate PHY
Date: Sun, 8 Aug 2004 22:05:32 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040808200532.GA19170@k3.hellgate.ch>
References: <411684D5.8020302@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266250AbUHHUFv@vger.kernel.org>
To: Manfred Spraul <manfred@colorfullife.com>
Content-Disposition: inline
In-Reply-To: <411684D5.8020302@colorfullife.com>
List-Id: netdev.vger.kernel.org

[ BCCed reporter in case he wants to weigh in on the issue ]

On Sun, 08 Aug 2004 21:53:57 +0200, Manfred Spraul wrote:
> Roger wrote:
> 
> >PHYs may come up isolated. Make sure we can send data to them. This code
> >section needs a clean-up, but I prefer to merge this fix in isolation.
> >
> What was the phyid value for the isolated PHYs?

I suspect it was 0, because another suggestion in the same message was to
start scanning at 0 rather than 1 (obsolete with current via-rhine code).

> I know that PHYs go into isolate mode if the startup id is wired to 0, 

Wouldn't that be s/go/can go/ ?

> but I haven't figured out what's necessary to initialize them: Just 
> clear the isolate bit or is it necessary to set the id to a nonzero value.

The proposed fix apparently worked for the PHY in question (LSI Logic
80225).

Roger
