From: Yannick <yannick.dirou@axetic.com>
Subject: Re: [Bug 10071] kernel hang in inet_init (PREEMPT_RCU problem)
Date: Fri, 29 Feb 2008 07:53:23 +0100
Message-ID: <47C7ABE3.6080004@axetic.com>
References: <bug-10071-11547@http.bugzilla.kernel.org/> <20080228205303.261D311D108@picon.linux-foundation.org> <20080228213457.GA2770@ami.dom.local> <20080229005823.GF14104@linux.vnet.ibm.com> <20080229043235.GA25167@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusa.axetic.com ([194.242.114.93]:54408 "EHLO eusa.axetic.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbYB2HTF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 02:19:05 -0500
In-Reply-To: <20080229043235.GA25167@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(In reply to comment #20)
 > Reply-To: paulmck@linux.vnet.ibm.com
 >
 > Would you be willing to try your test again after applying the
 > patch in http://lkml.org/lkml/2008/2/2/11 and rebuilding your
 > kernel?
 >
 > This patch does not appear to be in 2.6.25-rc3.  :-(
 >
 > I am reposting this patch separately.
 >
 >                                                         Thanx, Paul

Congratulations Paul and thanks a lot to Jarek , It works,
no more hang or slow boot :
[1.061675] Calling initcall 0xc03b8e10: inet_init+0x0/0x3ba()
[1.061895] NET: Registered protocol family 2
[1.339007] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[1.339470] TCP established hash table entries: 131072 (order: 8, 1048576 
bytes)
[1.340375] TCP bind hash table entries: 65536 (order: 9, 2359296 bytes)
[1.349809] TCP: Hash tables configured (established 131072 bind 65536)
[1.349906] TCP reno registered
[1.098514] initcall 0xc03b8e10: inet_init+0x0/0x3ba() returned 0.
[1.098604] initcall 0xc03b8e10 ran for 32 msecs: inet_init+0x0/0x3ba()

Yannick
