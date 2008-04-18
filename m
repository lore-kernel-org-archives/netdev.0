From: "pradeep singh rautela" <rautelap@gmail.com>
Subject: Re: [PATCH 5/5] tun: vringfd xmit support.
Date: Fri, 18 Apr 2008 23:31:29 +0530
Message-ID: <6bc632150804181101i701f220an20dddf54389be273@mail.gmail.com>
References: <200804181433.48488.rusty@rustcorp.com.au>
	<200804181441.10499.rusty@rustcorp.com.au>
	<200804181442.17251.rusty@rustcorp.com.au>
	<200804181443.24812.rusty@rustcorp.com.au>
	<6bc632150804180446u29e5dae9h986e1d255e584d21@mail.gmail.com>
	<2c0942db0804180725h88fa7d1mb8e85e5a8b0aede6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Max Krasnyansky <maxk@qualcomm.com>,
        virtualization@lists.linux-foundation.org
To: "Ray Lee" <ray-lk@madrabbit.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <2c0942db0804180725h88fa7d1mb8e85e5a8b0aede6@mail.gmail.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 18, 2008 at 7:55 PM, Ray Lee <ray-lk@madrabbit.org> wrote:
> On Fri, Apr 18, 2008 at 4:46 AM, pradeep singh rautela
>  <rautelap@gmail.com> wrote:
>  >
>  > On Fri, Apr 18, 2008 at 10:13 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
>
> >  >  +               /* How many pages will this take? */
>  >  >  +               npages = 1 + (base + len - 1)/PAGE_SIZE - base/PAGE_SIZE;
>  >
>  >  Hi Rusty,
>  >  A trivial suggestion, how about
>  >           npages = 1+(len -1)/PAGE_SIZE ?
>
>  That's not the same. In particular, his version accounts for the
>  fractional page at the beginning, while yours doesn't.

Oh thanks for correcting me Ray. :)
>
>  While it's tempting to use algebra to simplify things, it's not safe
>  to do so when the expression involves division over the integers. The
>  only care-free integer math in a computer is subtraction and ++.

I stand corrected.

Sorry for noise.

Thanks,
-- 
Pradeep Singh Rautela
http://eagain.wordpress.com
http://emptydomain.googlepages.com
