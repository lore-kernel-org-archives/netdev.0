From: Frans Pop <elendil@planet.nl>
Subject: Required sequence to set wireless parameters? (was: 2.6.29-rc8: Reported regressions from 2.6.28)
Date: Thu, 19 Mar 2009 16:02:56 +0100
Message-ID: <200903191602.58790.elendil@planet.nl>
References: <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com> <1237140665.24621.2.camel@johannes.local> <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain> <1237143683.24621.7.camel@johannes.local> <20090315202603.GA9077@elte.hu> <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com> <1237317742.31814.28.camel@johannes.local> <b6a2187b0903181958ke11abe7tdcbc4efeb950954d@mail.gmail.com> <b6a2187b0903182149x77e416ecuf73be2970173c601@mail.gmail.com> <1237455534.5100.56.camel@johannes.local> <1237455534.5100.56.camel@johannes.local> <20090319141311.GA3587@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, jeff.chua.linux@gmail.com,
	mingo@elte.hu, torvalds@linux-foundation.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, bunk@kernel.org,
	akpm@linux-foundation.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756906AbZCSPDV@vger.kernel.org>
In-reply-To: <20090319141311.GA3587@tuxdriver.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Thu, Mar 19, 2009 at 10:38:54AM +0100, Johannes Berg wrote:
>> On Thu, 2009-03-19 at 12:49 +0800, Jeff Chua wrote:
>> > # this needs patch to work ...
>> > iwconfig wlan0 mode Managed
>> > ifconfig wlan0 up
>> > iwconfig wlan0 essid xxx
>> > iwconfig wlan0 key restricted xxx
>> > iwconfig wlan0 ap auto channel auto
>> 
>> If you swap the key and essid lines, it will probably always work. But
>> I've yet to analyse your data to see why it doesn't in the other case.
> 
> That is what I was going to suggest.  I go so far as to say that you
> should set everything else before doing the "iwconfig wlan0 essid
> xxx" bit.

Mostly just curious, but is that actually required by some wireless 
standard? If not, is it really reasonable to ask userland to do things in 
that particular order?

Reason I ask is that for example when writing wireless support for e.g. a 
distro installation system, it seems most logical to *first* ask the user 
what network (ESSID) he wants to connect to. Next to check if we can 
connect to that network without additional authentication and only then, 
if needed, ask for keys etc.
If it's not possible to set that info in that logical order that seems 
rather restrictive to me and would probably mean that you'd have to reset 
AP, ESSID and possibly other settings before each incremental attempt.

Cheers,
FJP
