From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fw: unregister_netdevice(): negative refcnt, suggest patch against 2.6.11
Date: Sun, 10 Apr 2005 23:50:50 +0200
Message-ID: <20050410215050.GJ26731@postel.suug.ch>
References: <20050410034446.39e3025e.akpm@osdl.org> <20050410212727.GA13829@palmen.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Felix Palmen <fmp@palmen.homeip.net>
Content-Disposition: inline
In-Reply-To: <20050410212727.GA13829@palmen.homeip.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Felix Palmen <20050410212727.GA13829@palmen.homeip.net> 2005-04-10 23:27
> I've now tested this issue on a vanilla 2.6.11.7 kernel. I only applied
> my own patch from the previous post so that I am able to shut down the
> computer cleanly. So I did the following:
> 
> - boot 2.6.11.7
> - create a tap device with 'openvpn --mktun --dev tap0'
> - create /etc/netatalk/atalkd.conf with a single line 'tap0'
> - launch atalkd, wait.
> - stop atalkd.
> - destroy tap device with 'openvpn --rmtun --dev tap0'
> 
> refcnt was -256, very strange.

Is it always 256? Do you have any appletalk routes configured?
If so, is the 256 dependand on the number of routes?

I'm asking because:
ddp.c:          for (nodect = 0; nodect < 256; nodect++) {
ddp.c:          for (nodect = 0; nodect < 256; nodect++) {

However, I have not checked if this could be invovled at all.

> Would you consider my patch harmful? I intend using it for now, because
> otherwise, my system won't shut down cleanly any more...

Your system is not fully reliable with and without the patch so
it doesn't matter at all. ;->
