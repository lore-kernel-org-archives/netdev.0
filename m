From: "Nelson A. de Oliveira" <naoliv@gmail.com>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Fri, 18 Apr 2008 12:23:06 -0300
Message-ID: <9bfa9ae0804180823o1c3213ccj6ac1ab19b0b5cb94@mail.gmail.com>
References: <bug-10473-10286@http.bugzilla.kernel.org/>
	 <20080417171215.f7fbba3b.akpm@linux-foundation.org>
	 <200804181606.34853.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:19699 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526AbYDRPXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 11:23:11 -0400
Received: by yw-out-2324.google.com with SMTP id 5so411880ywb.1
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2008 08:23:06 -0700 (PDT)
In-Reply-To: <200804181606.34853.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Fri, Apr 18, 2008 at 11:06 AM, Michael Buesch <mb@bu3sch.de> wrote:
>  > > While booting the new 2.6.25 Kernel, it enters an infinite looping displaying
>  > > "b44: eth0: powering down PHY".
>  > > The system isn't freezed as magick SysRq keys works, but it just stay
>  > > displaying those messages. I am unable to dump any information using SysRq,
>  > > however (as the b44(...) messages are too fast).
>  > >
>  > > I will attach lspci output and my .config
>  > >
>  >
>  > Apparently a regression.
>
>  Can you add a dump_stack() call to the b44_halt() function and post the resulting logs?

What I get is:

Pid: 4, comm: ksoftirqd/0 Tainted: GF 2.6.25-naoliv1 #2
[<f8992420>] [<b0231ffd>] [<b02380b9>] [<b011ed60>] [<b01060f2>]
[<b011f059>] [<b011efe1>] [<b01297c8>] [<b0129790>] [<b010473f>]

Something is saying to me that this won't help too much and that
probably I need to enable something related with debug (what do I need
to enable, please?)

BTW, is it a way to "pause" the messages after dump_stack()?

Thank you!

Best regards,
Nelson
