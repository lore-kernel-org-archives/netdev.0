From: greear@candelatech.com
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Thu, 7 Nov 2002 10:16:51 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0211071013150.31376-100000@grok.yi.org>
References: <Pine.GSO.4.30.0211070823590.11358-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Greear <greearb@candelatech.com>, Donald Becker <becker@scyld.com>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0211070823590.11358-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Nov 2002, jamal wrote:
> Trash the machines harder. Try using smaller packets;

They are already dropping packets, I thought I'd try to get a slower run 
to work cleanly before trying something faster.  Precision is more
important to me than absolute throughput at this point.

Initial run with 256 sized rx-ring (and skb-recycle) shows better
performance (than with 1024 rx-ring)

Sent 6-mil packets (same setup as before), dropped 750 or so.  One NIC has 
dropped 2000 in one direction and 1325 in the other though...

An over-night run with 1024 rx-ring passed 152mil packets, dropped 75k or 
so.


Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear 
