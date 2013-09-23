From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to
	kernel
Date: Mon, 23 Sep 2013 14:24:31 -0700
Message-ID: <CAEP_g=_Di4yUzR0ka_Ma73DPKRoeCYW-ZZvQ=_n7OVDmpRKbTQ@mail.gmail.com>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
	<1378711207-29890-8-git-send-email-horms@verge.net.au>
	<CALnjE+p9g+GO71yjcNVG+y9ZzvT_==SLSqAAqGHU_jg=sx7Ynw@mail.gmail.com>
	<20130918220756.GA24919@verge.net.au>
	<CAEP_g=8+osWcHjj6pkGkid6djK9=CDf4U4qC97bY=GP0j=K3iw@mail.gmail.com>
	<20130922053800.GA4890@verge.net.au>
	<CALnjE+o_bcNbU6kv2eUBaNS4tincV+BmrFyJtZZRTaMPMVv8gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CALnjE+o_bcNbU6kv2eUBaNS4tincV+BmrFyJtZZRTaMPMVv8gw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Mon, Sep 23, 2013 at 12:47 PM, Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
> This patch does not work since vport-netdev does not include compat
> gso header. after including gso.h it gives me compiler error.
> Can you post combined patch with fixes?

I think it's probably because of this:

+#if 1 // LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
+#define dev_queue_xmit rpl_dev_queue_xmit
+#endif

But otherwise, I agree the approach is much nicer than what is currently there.
