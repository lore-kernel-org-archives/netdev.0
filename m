From: Markus =?ISO-8859-1?Q?H=E4stbacka?= <midian@ihme.org>
Subject: Re: [NET] 64 bit byte counter for 2.6.3
Date: Wed, 18 Feb 2004 22:43:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1077137014.18843.10.camel@midux>
References: <1077123078.9223.7.camel@midux>
	 <20040218101711.25dda791@dell_ss3.pdx.osdl.net>
	 <Pine.LNX.4.53.0402181527000.7318@chaos>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Kernel Mailinglist <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: root@chaos.analogic.com
In-Reply-To: <Pine.LNX.4.53.0402181527000.7318@chaos>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-02-18 at 22:32, Richard B. Johnson wrote:
> Manipulation of a 'long long' is not atomic in 32 bit architectures.
> Please explain how we don't care, if we shouldn't care. Also some
> /proc entries might get read incorrectly with existing tools.
Please, tell me all the tools, I'll test them. ifconfig and netstat
works correctly atleast.

And about the caring, is rx/tx bytes so important that they can't use
long long? I would care to see more than 4GB, and maybe some error in
the counter at some point (Have you _ever_ seen that happen?) than only
4GB.

And no, I didn't post this to be merged into the mainline kernel, just
to let users know that there maybe is an option for seeing maximum 4GB.

This has been working for me since, umm.. let's say 2.4.20. All the
tools I've needed have worked.

        Markus
