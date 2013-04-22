From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/2] genl: Allow concurrent genl
	callbacks.
Date: Mon, 22 Apr 2013 18:55:21 -0400 (EDT)
Message-ID: <20130422.185521.711925108684466632.davem@davemloft.net>
References: <1366320646-16903-1-git-send-email-pshelar@nicira.com>
	<20130422.161812.1075030033926378895.davem@davemloft.net>
	<CALnjE+pwo5_j8ChPEHGXWT2kc1U3mVE99xc=XDtp6XtPOytKGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CALnjE+pwo5_j8ChPEHGXWT2kc1U3mVE99xc=XDtp6XtPOytKGA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Date: Mon, 22 Apr 2013 13:41:41 -0700

> Therefore scatchpad in SKB is protected and parallel netlink dump operations
> can go only on different netlink sockets.

What about configuration changes running in parallel with the dump?

You must synchronize with those too, otherwise protecting the
intra-dump state is meaningless since the underlying objects
can change underneath the dump.
