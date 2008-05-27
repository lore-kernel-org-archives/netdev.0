From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug 10739] 8139too carrier state problem, was: PPPoE not
	working...
Date: Tue, 27 May 2008 08:06:53 +0000
Message-ID: <20080527080653.GA4229@ff.dom.local>
References: <bug-10739-11547@http.bugzilla.kernel.org/> <20080527071635.91D1C108048@picon.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: for.dev.null@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:62848 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757059AbYE0IDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 04:03:06 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1097678nfc.21
        for <netdev@vger.kernel.org>; Tue, 27 May 2008 01:03:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080517221018.0a31f9df.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I forward this subject to netdev list. IMHO modprobe shouldn't be
needed to get this driver RUNNING after plugging the wire. (I've tried
a similar card with 2.6.24 kernel and ifconfig eth0 up was enough).

If there is no good advice I think it would be better to close the
current report and reopen it with better title.

Regards,
Jarek P.


On 18-05-2008 07:10, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Sat, 17 May 2008 21:56:36 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=10739
>>
>>            Summary: PPPoE not working, if ethernet wire not plugged during
>>                     boot
>>            Product: Networking
...

On Tue, May 27, 2008 at 12:16:35AM -0700, bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=10739
> 
> 
> 
> 
> 
> ------- Comment #23 from for.dev.null@gmail.com  2008-05-27 00:16 -------
> success ! after doing the modprobe as suggested it started working !
> 
> eth0      Link encap:Ethernet  HWaddr 00:05:5D:42:52:DA
>           inet addr:xxx.xx.xxx.xxx  Bcast:169.24.255.255  Mask:255.255.0.0
>           inet6 addr: fe80::205:5dff:fe42:52da/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:239 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:106 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:6 txqueuelen:1000
>           RX bytes:89971 (87.8 KiB)  TX bytes:10182 (9.9 KiB)
>           Interrupt:185 Base address:0xb800
> 
> Is this is bug and where to file it ? Does it happen with every network card or
> just this one ? How do I get this fixed ?
> 
> Thanks a lot !!
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
