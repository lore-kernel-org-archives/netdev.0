From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: warning: massive change to conditional coding style in net?
Date: Tue, 01 Dec 2009 11:08:59 -0500
Message-ID: <4B153F9B.7050502@gmail.com>
References: <4B13A025.7000103@gmail.com> <1259603798.29779.293.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754133AbZLAQI6@vger.kernel.org>
In-Reply-To: <1259603798.29779.293.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> On Mon, 2009-11-30 at 05:36 -0500, William Allen Simpson wrote:
>> Over the past several days, David Miller (with help from Joe Perches)
>> made sweeping changes to the format of conditional statements in the
>> net tree -- the equivalent of mass patches that change spaces.
>> This makes writing patches for multiple versions of the tree very
>> difficult, and will make future pullups problematic.
> 
> If it makes getting tcp cookies accepted difficult,
> a reversion is simple.  That style isn't as important.
> 
Then why make an *un*important (yet sweeping) change?


> I think writing a single set of patches for multiple
> versions of linux is not feasible.  Feature changes
> occur in kernel source daily.
> 
My patches were carefully written and applied with small fuzz to .30,
and .31, and .32-rc3.


>> 	if (condition
>> 	    && condition
>> 	    && (condition
>> 	        || condition
>> 	        || condition)) {
> 
> The above is my personally preferred style.
> 
That seems fine to me.  And in some areas of the tree, nearly 100% of
other contributors, too.

My personally preferred style is the single spaced variant, that also
conforms to the strict letter of CodingStyle, to wit:

   Use one space around (on each side of) most binary and ternary operators


>> 	if (condition &&
>>              condition && (condition || condition ||
>> 	    condition)) {
> 
> Except for the odd spacing, this is the significant
> majority of net/ style.
> 
> The leading style was < 10%.  It's less now.
> 
That's only true in net/ -- since the overall tree was 18.7%, with
net/ < 10%, the density was *much* higher elsewhere.

But more important, at least to my thinking, is keeping patches simple
by conforming to the *existing* style in the section of code.  No
sweeping changes!
