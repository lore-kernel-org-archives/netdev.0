From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [2/3] via-rhine: de-isolate PHY
Date: Sun, 08 Aug 2004 21:53:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411684D5.8020302@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Roger wrote:

> PHYs may come up isolated. Make sure we can send data to them. This code
> section needs a clean-up, but I prefer to merge this fix in isolation.
>
What was the phyid value for the isolated PHYs?

I know that PHYs go into isolate mode if the startup id is wired to 0, 
but I haven't figured out what's necessary to initialize them: Just 
clear the isolate bit or is it necessary to set the id to a nonzero value.

--
    Manfred
