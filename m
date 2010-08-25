From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [Bugme-new] [Bug 16529] New: xennet driver crashes when using
 with pseudowire aka l2tpv3
Date: Wed, 25 Aug 2010 15:56:12 -0700
Message-ID: <4C759F8C.9050301@goop.org>
References: <bug-16529-10286@https.bugzilla.kernel.org/> <20100825153107.2f547f0e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Chris Wright <chrisw@sous-sol.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	James Chapman <jchapman@katalix.com>,
	heil@terminal-consulting.de,
	"Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from claw.goop.org ([74.207.240.146]:46895 "EHLO claw.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752501Ab0HYW4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 18:56:15 -0400
In-Reply-To: <20100825153107.2f547f0e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On 08/25/2010 03:31 PM, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Fri, 6 Aug 2010 12:46:18 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=16529
>>
>>            Summary: xennet driver crashes when using with pseudowire aka
>>                     l2tpv3
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: 2.6.35
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Other
>>         AssignedTo: acme@ghostprotocols.net
>>         ReportedBy: heil@terminal-consulting.de
>>         Regression: No
>>
>>
>> I tried to use use the new l2tpv3 implementation on two xen domU's but one of
>> them is crashing when the first l2tpv3 packet is received.
>>
>> As a great man mentioned: 
>> --
>> guessing that eth_type_trans() has tried to pull an ethernet header from
>> the skb and has run off the end, which suggests an issue with the skb
>> that was passed up. Does the ethernet driver do proper alignment of data
>> in its skbs? Perhaps it doesn't allocate as much headroom as other
>> drivers? Perhaps the L2TP code assumes things about the skb that aren't
>> valid..
>> --
>> Here is a link for the setup
>> http://www.pastebin.org/445975
>> and here a link with more details about the crash http://pastebin.org/449221

Please attach these to the bug or something; pastebin is not working for
me at the moment.

>> According the the hints from James Chapmann we tried generic x86 with a
>> different nic driver like e1000 and this works without any problem. 
>>
>> Iam using OpenWrt to create the system images. To speed up the process i would
>> prepare Xen images, make them available or whatever is wished because
>> pseudowire is already ready in OpenWrt Trunk so that every man also with "price
>> sensitivy" hardware can use it.
>>
> Seems to be a problem with xennet afacit?

Possibly.  What's a l2tpv3 and what does it do differently from other
protocols?

    J

