From: Karsten Desler <kdesler@soohrt.org>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Wed, 8 Dec 2004 23:06:01 +0100
Message-ID: <20041208220601.GA18066@quickstop.soohrt.org>
References: <20041206205305.GA11970@soohrt.org> <20041207211035.GA20286@quickstop.soohrt.org> <16822.12630.275389.575326@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Desler <kdesler@soohrt.org>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        jamal <hadi@cyberus.ca>, P@draigBrady.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16822.12630.275389.575326@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson <Robert.Olsson@data.slu.se> wrote:
>    rhash_entries=  [KNL,NET]
>                         Set number of hash buckets for route cache

IP: routing cache hash table of 131072 buckets, 1024Kbytes
A 3 percent improvement over the average cpu usage in the last 8 hours
compared to the same time yesterday.
Still in the noise.

I'm going to try a day without netfilter next and then the realloc_skb
patch.

Cheers,
 Karsten
