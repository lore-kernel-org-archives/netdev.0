From: "David S. Miller" <davem@redhat.com>
Subject: Re: do_gettimeofday
Date: Fri, 3 Oct 2003 02:23:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003022338.6ffed45d.davem@redhat.com>
References: <3F7C6F3B.6070502@sgi.com>
	<20031002125625.72b8c0a7.shemminger@osdl.org>
	<20031003004133.3148c39a.davem@redhat.com>
	<20031003082642.GF42593@gaz.sfgoth.com>
	<20031003012754.23de3f66.davem@redhat.com>
	<20031003084847.GH42593@gaz.sfgoth.com>
	<20031003015220.7ee6e451.davem@redhat.com>
	<20031003092617.GI42593@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20031003092617.GI42593@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Oct 2003 02:26:17 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> I was more thinking about the other timestamp users.  I don't consider
> tcpdump something that needs as much optimization.

Well, it's is the fact that usage of the timestamp is rare which we're
trying to take advantage of.

The whole idea is that fast_timestamp_to_timeval() can be a bit slow
or suboptimal in order to make store_fast_timestamp() a lot faster
or access less shared or locked state.
