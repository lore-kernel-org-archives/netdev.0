From: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [GIT net-next] Open vSwitch
Date: Tue, 14 Jan 2014 10:46:15 +0100
Message-ID: <52D50767.6050906@redhat.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com>
	<52CD657F.7080806@citrix.com>
	<CAEP_g=_pQpH--V+7GSrjGP2z=0TBD_37yXjzTdeKG+2OF3aRaw@mail.gmail.com>
	<52D42A9E.1030805@citrix.com> <52D4857C.7020902@citrix.com>
	<CAEP_g=8nG6AHV9Y+5=48nPhkf5Oe=mG8EiyaKSqN4omnmGhv4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=8nG6AHV9Y+5=48nPhkf5Oe=mG8EiyaKSqN4omnmGhv4A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On 01/14/2014 02:30 AM, Jesse Gross wrote:
>> And it works. I guess the last one causing the problem. Might be an
>> important factor, I'm using 32 bit Dom0.
>
> I think you're probably right. Thomas - can you take a look?
>
> We shouldn't be doing any zerocopy in this situation but it looks to
> me like we don't do any padding at all, even in situations where we
> are copying the data.

I'm looking into this now. The zerocopy method should only be attempted
if user space has announced the ability to received unaligned messages.

@Zoltan: I assume you are using an unmodified OVS 1.9.3?
