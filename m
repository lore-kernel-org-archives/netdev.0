From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail command
 as non-root
Date: Thu, 20 Mar 2008 15:52:05 +0300
Message-ID: <47E25DF5.3090107@openvz.org>
References: <47D98510.60801@imap.cc> <20080319.154947.78332548.davem@davemloft.net> <939d53060803200126k563b9ae7l7197dea4e96ba1ed@mail.gmail.com> <200803201121.07633.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Benjamin Thery <ben.thery@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	tilman@imap.cc, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org,
	dlezcano@fr.ibm.com, xemul@openvz.org, ebiederm@xmission.com
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756134AbYCTMxV@vger.kernel.org>
In-Reply-To: <200803201121.07633.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki wrote:
> On Thursday, 20 of March 2008, Benjamin Thery wrote:
>> On Wed, Mar 19, 2008 at 11:49 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Andrew Morton <akpm@linux-foundation.org>
>>>  Date: Wed, 19 Mar 2008 14:16:08 -0700
>>>
>>>
>>>  > Although this is advertised as a 2.6.25-rc5-mm1 problem, I assume the
>>>  > regression is also in mainline? 2.6.25-rc6?
>>>
>>>  It is in 2.6.25-rc6, correct.
>>>
>>>  If Pavel or someone else doesn't produce a good fix soon
>>>  I'll revert the guilty change as this bug is worse than
>>>  the problem that changeset fixes.
>> Andre Noll sent a patch to LKML, acked by Pavel:
>>
>> "Fix permissions of /proc/net"
>> http://thread.gmane.org/gmane.linux.kernel/655148
> 
> Have you tested that patch?

I did - works OK, that's why I Acked it.

> Rafael
> 
