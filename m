From: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 4/7] openvswitch: add ipv6 'set'
	action
Date: Wed, 12 Dec 2012 10:38:44 -0800
Message-ID: <CA+mtBx-84PQoHmauNpN4vYLWXcJdESMMep849DQcUAjkmC7PXQ@mail.gmail.com>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
	<1354214149-33651-5-git-send-email-jesse@nicira.com>
	<CA+mtBx-Zf9FNf11H9RM12etHnJ1bPpM_Eyc4mR7E6xsb7sUP2Q@mail.gmail.com>
	<CAEP_g=-1aWGsjR55AaD6sLLt4QzbYgUs-3hfNNONrrf8MDwSyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=-1aWGsjR55AaD6sLLt4QzbYgUs-3hfNNONrrf8MDwSyA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

> At an implementation level, the goal is definitely to share as much
> code as possible.  Some of that was obviously done to support this
> patch and I'm sure there are more areas where it could be taken
> further.
>
> At a more conceptual level we've explored this path a number of times
> and it's never been attractive since it has a tendency to drag more
> OVS code into other parts of the kernel and generally make things
> worse for everybody.  Of course, it's hard to say without knowing what
> you're thinking.  Do you have a specific proposal?

Where is the line drawn?  Is the intent that over the next five years
that functionality will be added ad hoc increments to make OVS have
the same functionality as IP tables, tc, routing?  Are we going to
have things like NAT, stateful firewalls, DDOS mechanisms implemented
in OVS (we already have people proposing such things!).
