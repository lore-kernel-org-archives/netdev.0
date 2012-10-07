From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] openvswitch: using nla_for_each_X to simplify
	the code
Date: Sun, 07 Oct 2012 14:33:51 -0400 (EDT)
Message-ID: <20121007.143351.311613044901717710.davem@davemloft.net>
References: <CAPgLHd8hY-nZWaG-meEk1MtY5Rj_26Lj1bxH=jtn20jxni+U8g@mail.gmail.com>
	<CAEP_g=_D1m+p0POKC5ozFEgfEhGzN9G_+Yja_iBz4guuRe6Nog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org,
	weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=_D1m+p0POKC5ozFEgfEhGzN9G_+Yja_iBz4guuRe6Nog-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Date: Sun, 7 Oct 2012 11:30:51 -0700

> On Sun, Oct 7, 2012 at 6:42 AM, Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
>>
>> Using nla_for_each_nested() or nla_for_each_attr()
>> to simplify the code.
>>
>> dpatch engine is used to auto generate this patch.
>> (https://github.com/weiyj/dpatch)
>>
>> Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
> 
> It is done this way intentionally to avoid checks on the fast path for
> conditions that have already been validated.

Agreed, I'm not applying this patch.
