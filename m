From: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Subject: Re[2]: [partially solved] tcp_window_scaling degrades performance
Date: Tue, 20 Jul 2004 12:46:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1802866788.20040720124621@dns.toxicfilms.tv>
References: <962257105.20040719201304@dns.toxicfilms.tv>
 <Pine.NEB.4.33.0407191512220.7093-100000@dexter.psc.edu>
Reply-To: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0407191512220.7093-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

JH> Could you get sender-side dumps?  Receiver-side ones don't really contain
JH> as much information.
I could only get before-firewall-that-propably-screws-things-up dumps.
I will surely do that too.
Locally it's not affected.

JH> What happens if you set tcp_default_win_scale to 0, but leaving
JH> tcp_window_scaling to 1?  I suspect this a lot more than the changeset
JH> your cite below, though if it's really better with that changeset backed
JH> out, could you get a dump of that, too?
With tcp_windows_scaling to 1 and tcp_default_win_scale to 0
everything seems normal again. Dumps of this will follow soon.

Also, to fix the firewall we need to prolong the licence to get support to
apply the hotfixes or to do a kernel upgrade or whatever would be
necesarry. For this I will have to wait a bit :-(

Regards,
Maciej
