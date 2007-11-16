From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 9391] New: Netgear GA320T(tg3) strange errors and non-workingness
Date: Fri, 16 Nov 2007 09:30:07 +0100
Message-ID: <20071116083007.GA2124@ff.dom.local>
References: <20071115181809.592a110c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	mchan@broadcom.com, Andrew Morton <akpm@linux-foundation.org>
To: Jon Nelson <jnelson@jamponi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:40494 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752305AbXKPIZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 03:25:57 -0500
Content-Disposition: inline
In-Reply-To: <20071115181809.592a110c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-2007 03:18, Andrew Morton wrote:
> On Thu, 15 Nov 2007 18:04:19 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=9391
>>
>>            Summary: Netgear GA320T(tg3) strange errors and non-workingness
>>            Product: Drivers
>>            Version: 2.5
>>      KernelVersion: 2.6.22.12 (openSUSE 10.3)
...

I see we have a new thread for this...

Jon, maybe it's only me, but this really looks strange. I don't know
this board, but probably these interrupts shouldn't look like this.
It seems there is a problem with detecting your apic. I'm not sure
if this is a default SUSE kernel, but maybe it would be better to
try some current live-cd distro with good hardware detection. tg3
card & driver seem to have quite good opinions, especially if msi
interrupts could be used.

Btw., these logs (dmesg, lspci) could be much longer... (Somebody
might even think you have something to hide; it would be better to
mask only personal data then.)

Cheers,
Jarek P.
