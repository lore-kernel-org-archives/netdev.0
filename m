From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: Documentation: rw_lock lessons learned
Date: Fri, 13 Nov 2009 11:15:42 -0500
Message-ID: <4AFD862E.6070105@gmail.com>
References: <4AF9C540.5090403@gmail.com>	<20091110180646.2e5859a8@nehalam>	<4AFAEF78.4080807@gmail.com>	<20091111093724.4f40a48d@nehalam>	<4AFBEC44.9030409@gmail.com>	<4AFC5E3F.7070609@earthlink.net> <20091112150029.1a26c641@nehalam> <4AFD1FF1.7080906@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, sclark46@earthlink.net,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756093AbZKMQPu@vger.kernel.org>
In-Reply-To: <4AFD1FF1.7080906@s5r6.in-berlin.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Richter wrote:
> Stephen Hemminger wrote:
>> On Thu, 12 Nov 2009 14:13:03 -0500
>> Stephen Clark <sclark46@earthlink.net> wrote:
>>> How up to date is this doc?
>>>
>>> http://www.kernel.org/pub/linux/kernel/people/rusty/kernel-locking/index.html
>>>
>> Out of date.
>> 1. Missing mutex's which have largely replaced semaphores.
>>
>> 2. Missing change to lock initialization in later kernels.
>>
>> 3. Missing description of lock dependency checker which should be in same guide.
> 
> 4. The section on atomic reference counting should refer to <linux/kref.h>.

I'd also read that, and that's where I got some of my wrong thinking.  But
that does point to Documentation/spin_locks.txt, which I took to be
authoritative (and followed).  That's the reason spin_locks.txt should be
updated, as others are having the same problems....

Anybody have answers/updates to Linus's concerns about "pretty old and
bogus language"?
