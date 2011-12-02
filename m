From: Zhi Yong Wu <zwu.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] datapath: Fix build breakage on kernel 2.6.40
Date: Fri, 2 Dec 2011 10:25:21 +0800
Message-ID: <CAEH94Li8gdMZnwSHG_xQj761uRxedRX2nUVmhFV4Kt_EDeuzYQ@mail.gmail.com>
References: <1322042318-4809-1-git-send-email-zwu.kernel@gmail.com>
	<CAEP_g=9CNRE=-B2V2=-CQA2MyzOsoqXPP_rjjvqGKWw_peNOkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, aliguori-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	stefanha-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=9CNRE=-B2V2=-CQA2MyzOsoqXPP_rjjvqGKWw_peNOkg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Thu, Dec 1, 2011 at 5:55 AM, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, Nov 23, 2011 at 1:58 AM, Zhi Yong Wu <zwu.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> diff --git a/datapath/linux/compat/include/linux/skbuff.h b/datapath/lin=
ux/compat/include/linux/skbuff.h
>> index 311bfdb..22ba2e6 100644
>> --- a/datapath/linux/compat/include/linux/skbuff.h
>> +++ b/datapath/linux/compat/include/linux/skbuff.h
>> @@ -239,7 +239,7 @@ static inline struct page *skb_frag_page(const skb_f=
rag_t *frag)
>> =A0}
>> =A0#endif
>>
>> -#if LINUX_VERSION_CODE < KERNEL_VERSION(3,0,0)
>> +#ifndef HAVE_SKB_RESET_MAC_LEN
>
> 2.6.40 is the early name for 3.0. =A0Does it work if you just replace
> the check with KERNEL_VERSION(2,6,40)?
Yeah, it can work now, but i don't know if this issue exist on other
old kernel version < 2.6.40.

Should we send one updated patch for this based on your suggestion?


-- =

Regards,

Zhi Yong Wu
