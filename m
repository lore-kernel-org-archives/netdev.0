From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fw: [Bugme-new] [Bug 3527] New: ssh does not work with 2.6.9rc3
Date: Fri, 8 Oct 2004 20:10:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008181036.GC19714@rei.reeler.org>
References: <20041008104801.0dd96536.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: albie@alfarrabio.di.uminho.pt
Content-Disposition: inline
In-Reply-To: <20041008104801.0dd96536.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>  With this kernel, the sis ethernet bug is fixed (well, at least I can do a ping
> -f without losing packets), SATA works but... wonder... ssh doesn't.
> 
> If I have a public key on other machine without passphrase, it works.
> If not....

Could you provide your .config and a dump of the network
traffic a few seconds before, during and after the ssh session?
(tcpdump -s -w ...)

> Now, that file really doesn't exist. But it isn't needed with the old kernel.
> So, what 2.6.9 rc 3 has that 2.6.7 don't?

I have the feeling that the bug is related to the calculation of
some networking related threshold resultung in wrong values right
after booting time.
