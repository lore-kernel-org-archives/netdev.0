From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: gigabit trouble
Date: Fri, 30 Jul 2004 20:54:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730205412.A15669@electric-eye.fr.zoreil.com>
References: <b71082d8040729094537e59a11@mail.gmail.com> <20040729210401.A32456@electric-eye.fr.zoreil.com> <b71082d80407291541f9d6f93@mail.gmail.com> <b71082d804073008157cf1d6c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart Alewijnse <scarfboy@gmail.com>
Content-Disposition: inline
In-Reply-To: <b71082d804073008157cf1d6c0@mail.gmail.com>; from scarfboy@gmail.com on Fri, Jul 30, 2004 at 05:15:41PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bart Alewijnse <scarfboy@gmail.com> :
[...]
> Definately. I've now seen speeds up to 22MB/s, but only in pure
> network benching (netio), and only with udp, although I guess
> that makes a some sense.

It seems low. On a non-napi setup, I'd expect your celeron box to
stand at least 20~30 kIRQ/s if the hardware is not flawed.

[...]
> I assume the 20MB/s top speed on my gbit cards is io limiting,
> and possibly the fact that they're 32bit cards in 33mhz slots.
> Still, it's far from impressive. Any suggestions (on where to
> go) about improving it?

See Documentation/networking/ip-sysctl.txt and the r/wmem parameters
for a start. The 2.6.8-rc2-mm1 version of the r8169 driver is suggested.

A dumb 'vmstat 1' output during test could give some hint.

Can I assume that the systems are stable if not fast ?

--
Ueimor 
