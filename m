From: "Nelson A. de Oliveira" <naoliv@gmail.com>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Fri, 18 Apr 2008 14:12:34 -0300
Message-ID: <9bfa9ae0804181012l451687d8o7e6ce1f5213ff716@mail.gmail.com>
References: <bug-10473-10286@http.bugzilla.kernel.org/>
	 <200804181606.34853.mb@bu3sch.de>
	 <9bfa9ae0804180823o1c3213ccj6ac1ab19b0b5cb94@mail.gmail.com>
	 <200804181732.48546.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:14870 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757318AbYDRRMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 13:12:40 -0400
Received: by yw-out-2324.google.com with SMTP id 5so441417ywb.1
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2008 10:12:34 -0700 (PDT)
In-Reply-To: <200804181732.48546.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Fri, Apr 18, 2008 at 12:32 PM, Michael Buesch <mb@bu3sch.de> wrote:
>  Ehm, please enable CONFIG_KALLSYMS.

Right. Sorry.

Here it is:

Pid: 4, comm: ksoftirqd/0 Tainted: GF 2.6.25-naoliv #4

[<f899df84>] b44_halt+0x68/0x7f [b44]

[<f899f432>] b44_poll+0x36a/0x405 [b44]

[<b02393ad>] net_rx_action+0x63/0x131

[<b011ee60>] __do_softirq+0x5a/0xa5

[<b01061e2>] do_softirq+0x52/0x84

[<b011f159>] ksoftirqd+0x78/0x110

[<b011f0e1>] ksoftirqd+0x0/0x110

[<b01298d4>] kthread+0x38/0x60

[<b012989c>] kthread+0x0/0x60

[<b010474b>] kernel_thread_helper+0x7/0x10

Anything else that I can do to help, please?

Thank you!

Best regards,
Nelson
