From: Sean Neakums <sneakums@zork.net>
Subject: Re: [2.6.0-test1-mm1] TCP connections over ipsec hang after a few
 seconds
Date: Sun, 20 Jul 2003 13:29:24 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6u8yqt8jq3.fsf@zork.zork.net>
References: <Mutt.LNX.4.44.0307201552580.22965-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0307201552580.22965-100000@excalibur.intercode.com.au> (James
 Morris's message of "Sun, 20 Jul 2003 15:58:13 +1000 (EST)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Morris <jmorris@intercode.com.au> writes:

> On Sat, 19 Jul 2003, Sean Neakums wrote:
>
>> twenty.  The problem seems unrelated to the amount of data
>> transferred; I've tried both bulk rsync transfers and ssh sessions.
>> I've also tested the same boxes over 100baseT; still happens.
>
> It sounds a bit like a pmtu problem related to the wireless bridge, but 
> that would be dependent on amount of data transferred and should not 
> happen on 100baseT.

I am seeing a lot of "pmtu discvovery on SA AH/03537192/c0a80003" type
messages (I forgot to check for them when on 100baseT; will recheck
that).  Are these indicative of such a problem?  I seem to recall that
reducing the max MTU is not as straightforward as just adjusting the
interfaces' mtu setting.  What should I do to eliminate pmtu as the
source of the problem?

> Transport mode (just blowfish encryption) looks to be working ok for me,
> I'm able to ftp uncompressed kernel tarballs between two boxes over 
> gigabit ethernet with no apparent problems.

I had been using 3des with AH; just retried with blowfish 448 and no
AH with much the same result.
