From: Andi Kleen <ak@suse.de>
Subject: Re: network delay simulation
Date: Wed, 17 Mar 2004 00:00:48 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040317000048.10d9f52c.ak@suse.de>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Mar 2004 15:10:58 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Still bumming around for how to easily simulate long latencies.
> There is NISTnet but that is fugly old 2.2 code; and Dummynet, and hitbox 
> which are FreeBSD based. The existing traffic shaper might do, but it seems
> to be limited to lower speed lines and needs some work (using atomic_set
> do own locking for instance).
> 
> Probably "the cowboy way" would be to right a new net/scheduler to just
> do FIFO delay.
> 
> Any ideas/comments? Somebody have some code sitting in a drawer?

iirc there was a 2.4 port of NistNet. Porting it to 2.6 is probably
not that much work.

-Andi
