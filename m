From: James Morris <jmorris@intercode.com.au>
Subject: Re: [2.6.0-test1-mm1] TCP connections over ipsec hang after a few
 seconds
Date: Mon, 21 Jul 2003 01:21:24 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307210116070.24197-100000@excalibur.intercode.com.au>
References: <6u8yqt8jq3.fsf@zork.zork.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Sean Neakums <sneakums@zork.net>
In-Reply-To: <6u8yqt8jq3.fsf@zork.zork.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 20 Jul 2003, Sean Neakums wrote:

> I am seeing a lot of "pmtu discvovery on SA AH/03537192/c0a80003" type
> messages (I forgot to check for them when on 100baseT; will recheck
> that).  Are these indicative of such a problem?

Yes.

With the 100baseT configuration, are the systems on the same segment?

It might help to provide tcpdumps from each end, ifconfig output for each 
interface and setkey configuration (without the wlan bridging).


- James
-- 
James Morris
<jmorris@intercode.com.au>
