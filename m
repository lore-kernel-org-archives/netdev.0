From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Sun, 31 Oct 2010 06:42:45 -0700 (PDT)
Message-ID: <20101031.064245.35056660.davem@davemloft.net>
References: <20101030.183257.70183832.davem@davemloft.net>
	<1288516747.4050.10.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288516747.4050.10.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 31 Oct 2010 10:19:07 +0100

> On Sat, 2010-10-30 at 18:32 -0700, David Miller wrote:
>> Last pull request before 2.6.37-rc1, I really wanted to get your
>> sendto/recvfrom patch in here as well as the RDS fixes.
>> 
>> I did a bunch of tests with the various I/O calls using different
>> lengths, like 10, (2^31 - 1), 2^31, 2^32, and larger on 64-bit and it
>> all seems to be doing the right thing at least with TCP and UDP.
> [...]
>> 7) RDS fixes from you and Andy Grover.
> [...]
> 
> Aren't the generic length limiting changes (8acfe46 and 253eacc) also
> supposed to cover the overflow issues with TIPC?  Or are those still
> unfixed?

Yes, the TIPC issues should be cured by those generic networking changes.
