From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: IOV iterator bug in net tree
Date: Wed, 1 Jun 2016 17:54:08 -0700
Message-ID: <CAKgT0Ue8Uufpq+5oyCW7tKJzX1waDnPC+KEnjOeBbQi9wn2oWw@mail.gmail.com>
References: <CAKgT0UfZFpUVNHnAjem3yCvf6n-EezqLnZerduQi3jQe76RK7Q@mail.gmail.com>
	<20160601.174225.2184872288386003765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160601.174225.2184872288386003765.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 1, 2016 at 5:42 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Fri, 27 May 2016 21:32:39 -0700
>
>> On Fri, May 27, 2016 at 11:21 AM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>>> I started out this morning by trying to run DevStack on the latest
>>> "net' kernel and it looks like I am hanging on some sort of locking
>>> problem with RabbitMQ.  Specifically I am seeing one CPU jump to 100%
>>> with perf showing that I am spinning on a lock.
>>>
>>> I'm working to bisect it now, but just thought I would put it out
>>> there if anybody had already root caused this issue.  Below is a few
>>> traces to the spin lock call on the spinning CPU:
>>
>> I misread the perf trace.  I wasn't spinning on a lock I was spinning
>> on the IOV iterator.  It just happened to push the lock to the top of
>> the perf trace.  I bisected it down to the recent change in
>> iterate_and_advance which was already fixed in Linus's tree in commit
>> 19f18459330f "do 'fold checks into iterate_and_advance()" right'.
>
> Since I resynced both of my trees with Linus's, this should be resolved
> now, right?

Yes, I pulled the latest net tree a few hours ago and it is working
without any issues.

Thanks.

- Alex
