From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [patch net-next] net: squash ->rx_handler and
 ->rx_handler_data into single rcu pointer
Date: Mon, 08 Apr 2013 12:32:40 -0400
Message-ID: <1365438760.25498.21.camel@gandalf.local.home>
References: <1364659034-7049-1-git-send-email-jiri@resnulli.us>
	<f72ccc9e-b09e-4abb-a0ce-a6516138b25c@email.android.com>
	<20130330193210.GD1544@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, paulmck-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	streeter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nicolas.2p.debian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20130330193210.GD1544-RDzucLLXGGI88b5SBfVpbw@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-03-30 at 20:32 +0100, Jiri Pirko wrote:

> >This doesn't solve anything. The CPU can be executing func when you set it to null.  Then you have the same problem.  This patch shows you still don't understand the bug.  
> 
> rx_handler->func is never set to NULL and is valid for all rx_handler (port_priv)
> lifetime.
> 

Ah, you're right. I'll look deeper at this patch after reading the
thread.

This is what I get for trying to review a patch reading it on my android
phone ;-)

-- Steve
