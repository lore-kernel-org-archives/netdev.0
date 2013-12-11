From: Christian Grothoff <grothoff@in.tum.de>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity
 protection
Date: Wed, 11 Dec 2013 23:53:41 +0100
Message-ID: <52A8ECF5.3070604@in.tum.de>
References: <52A75EF8.3010308@in.tum.de> <20131211.150137.368953964178408437.davem@davemloft.net> <52A8C8B4.4060109@in.tum.de> <20131211122637.75b09074@nehalam.linuxnetplumber.net> <87bo0nulkt.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, knock@gnunet.org, jacob@appelbaum.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87bo0nulkt.fsf@tassilo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/2013 10:25 PM, Andi Kleen wrote:
> Stephen Hemminger <stephen@networkplumber.org> writes:
>>
>> The point is that doing it outside of TCP core is safer, less error prone
>> and more flexible.
> 
> Or to put the question differently: what hooks would be needed to make
> this efficiently work in user space?
> 
> It could be something like this: Firewall the port with forwarding the 
> SYN packets using nfqueue, check for the SYN having the right magic,
> change a firewall rule, re-inject using nfqueue (not fully sure how
> well that works)

... and then do the same for the first TCP packet with payload? And you
seriously would consider that "safer" or "less error prone", starting
with the design complexity?  I mean, if this was a patch for GNU Hurd,
I'd at least understand the strong urge to do everything in userspace...
