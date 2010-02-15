From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v4 4/7] tcp: input header length, prediction, and timestamp
 bugs
Date: Mon, 15 Feb 2010 16:24:12 -0500
Message-ID: <4B79BB7C.6020507@gmail.com>
References: <4B793CAA.2030902@gmail.com> <4B793E8F.30208@gmail.com> <20100215151055.GG21783@one.firstfloor.org> <4B799A86.8040303@gmail.com> <20100215191548.GH21783@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100215191548.GH21783@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Mon, Feb 15, 2010 at 02:03:34PM -0500, William Allen Simpson wrote:
>> Andi Kleen wrote:
>>> Is this a bug fix? 
>>>
>> Yes.  One of many, all inter-related.
>>
> It's useful to distingush bug fixes from cleanups from optimizations etc.
> ...

The bug fixes depend on the cleanups.
  * 1/7 has the new functions.
  * 2/7 has bug fixes that require the new functions.
  * 3/7 fixes (and optimizes) the incoming code path, so that
  * 4/7 can fix the bugs.
  * 5/7 is needed to test the code from part 1.
  * 6/7 is the cleanup of parsing (also fixes some bugs introduced by
    davem's patch in December), so that
  * 7/7 can fix the bugs.

I originally tried submitting these as separate individual pairs of
patches (in November, December, January), but nobody paid any attention.
