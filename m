From: David Miller <davem@davemloft.net>
Subject: Re: CVE-2014-9900 fix is not upstream
Date: Tue, 23 Aug 2016 11:24:06 -0700 (PDT)
Message-ID: <20160823.112406.549221808236512285.davem@davemloft.net>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
        <20160823.094029.1244944495918162255.davem@davemloft.net>
        <1471973727.13300.162.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: luis.henriques@canonical.com, avijitnsec@codeaurora.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471973727.13300.162.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 23 Aug 2016 18:35:27 +0100

> On Tue, 2016-08-23 at 09:40 -0700, David Miller wrote:
>> From: Luis Henriques <luis.henriques@canonical.com>
>> Date: Tue, 23 Aug 2016 14:41:07 +0100
>> 
>> > Digging through some old CVEs I came across this one that doesn't
>> seem be
>> > in mainline.  Was there a good reason for not being sent upstream? 
>> Maybe it was
>> > rejected for some reason and I failed to find the discussion.
>> 
>> Because the patch is completely bogus, and thus so is the CVE.
>> 
>> The variable initializer clears out the entire structure.
>> 
>> Until you can show compiler output from gcc that shows it not
>> initializing the structure I will not apply this patch because I know
>> that it faithfully does.
> 
> On some versions and architectures.  Can you guarantee that you will
> notice when an exception appears?

Again, show me the assembler output exhibiting the lack of
initialization, for this specific structure and situation.

That's all that I'm asking.
