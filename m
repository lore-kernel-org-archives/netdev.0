From: "Nelson A. de Oliveira" <naoliv@gmail.com>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Fri, 18 Apr 2008 14:43:57 -0300
Message-ID: <9bfa9ae0804181043v60b7c92boef1c025ce04cfe37@mail.gmail.com>
References: <bug-10473-10286@http.bugzilla.kernel.org/>
	 <200804181732.48546.mb@bu3sch.de>
	 <9bfa9ae0804181012l451687d8o7e6ce1f5213ff716@mail.gmail.com>
	 <200804181919.17456.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:19497 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757359AbYDRRoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 13:44:14 -0400
Received: by yw-out-2324.google.com with SMTP id 5so449484ywb.1
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2008 10:43:57 -0700 (PDT)
In-Reply-To: <200804181919.17456.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Fri, Apr 18, 2008 at 2:19 PM, Michael Buesch <mb@bu3sch.de> wrote:
> On Friday 18 April 2008 19:12:34 Nelson A. de Oliveira wrote:
>  > Anything else that I can do to help, please?
>
>  Please apply this patch and send me the messages.

b44_poll: istat = 0x00000400

b44: eth0: powering down PHY


Pid: 0, comm: swapper Not tainted 2.6.25-naoliv1 #4

[<f899df84>] b44_halt+0x68/0x7f [b44]

[<f88f4440>] b44_poll+0x378/0x415 [b44]

[<b010453b>] common_interrupt+0x23/0x28

[<b02393ad>] net_rx_action+0x63/0x131

[<b011ee60>] __do_softirq+0x5a/0xa5

[<b01061e2>] do_softirq+0x52/0x84

[<b013d666>] handle_fasteoi_irq+0x0/0xad

[<b011ed3e>] irq_exit+0x35/0x76

[<b01062ad>] do_IRQ+0x99/0xb0

[<b010453b>] common_interrupt+0x23/0x28

[<f886700b>] acpi_idle_enter_bm+0x28c/0x2fd6 [processor]

[<b022602b>] cpuidle_idle_call+0x55/0x86

[<b0225fd6>] cpuidle_idle_call+0x0/0x86

[<b01028d3>] cpu_idle+0x8c/0xbc

I have increased the delay now.  This is the first message that
appears. It seems that after some time it starts to display the other
lines from my last email (Pid 4, comm: ksoftirqd/0 ...).

Best regards,
Nelson
