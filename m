From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: [PATCH 4/5] r8169: ethtool message level control
Date: Sat, 12 Mar 2005 12:30:44 +0000
Message-ID: <4232E0F4.8020103@phekda.gotadsl.co.uk>
References: <20050309113402.05d25e49@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050309113402.05d25e49@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.


Stephen Hemminger wrote:
> Add ethtool message level control support. This is the standard way
> to enable/disable console log messages.  Also, ratelimit the too much
> work at interrupt message, so if under massive packet load the console
> doesn't get flooded.
[snip]

Works fine for me on my Athlon64 laptop with a 8169 with built-in PHY.

Testing:

* Remove Ethernet cable, insert module (no params), then 
"/etc/init.d/network start". Check I get the "PHY reset until link up" 
message.

* "ethtool -s eth0 msglvl 0". Restart networking. Check I get no PHY 
reset message.

* Remove module. Reinsert module with "debug=16" param. Restart 
networking. Check I get PHY reset message plus chip info in dmesg.

* Insert cable, restart networking.

Bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
