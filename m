From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv2 vringh 1/3] remoteproc: Add support for vringh (Host
	vrings)
Date: Fri, 22 Feb 2013 11:12:13 +1030
Message-ID: <87k3q1faca.fsf@rustcorp.com.au>
References: <1360669793-6921-1-git-send-email-sjur.brandeland@stericsson.com>
	<1360669793-6921-2-git-send-email-sjur.brandeland@stericsson.com>
	<CAK=Wgbb0EeiCh504jsoX+izzi+ZogfEDttz2cHRd4pVXvQunQw@mail.gmail.com>
	<8738wqgok6.fsf@rustcorp.com.au>
	<CAK=WgbYt6mQeJ+4kCFsfGppfaq3JcS6OedNE+ZGd4itfR1hU4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>,
	Sjur =?utf-8?Q?Br=C3=A6ndeland?= <sjur@brendeland.net>,
	Linus Walleij <linus.walleij@linaro.org>, Ido Yariv <ido@wizery.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Erwan Yvin <erwan.yvin@stericsson.com>,
	virtualization <virtualization@lists.linux-foundation.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Sjur =?utf-8?Q?Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: Ohad Ben-Cohen <ohad@wizery.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAK=WgbYt6mQeJ+4kCFsfGppfaq3JcS6OedNE+ZGd4itfR1hU4A@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Ohad Ben-Cohen <ohad@wizery.com> writes:
> On Thu, Feb 21, 2013 at 8:37 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
>> Hmm... I clearly jumped the gun, assuming consensus was already reached.
>> I have put these patches *back* into pending-rebases, and they will not
>> be merged this merge window.
>
> Thanks.
>
> What do you think about creating some virtio-level wrappers for the
> vringh handlers?
>
> I don't think we're going to stop with caif as the only vringh user,
> and it could be nice if we follow the virtio spirit of decoupling the
> drivers from the low level implementation. It sure did prove itself
> when the remoteproc use cases started showing up, and it's neat.

The problem space is a bit different.  My immediate concern is getting
vhost (and thus vhost_net/blk) to use vringh: I wanted to unify the
in-userspace and in-kernelspace ring implementations.  We don't have
that issue in virtqueue.c.

vhost is (will be) the higher abstraction for in-userspace rings,
perhaps we want an equivalent for in-kernelspace rings.  I'm happy to
look at patches, but I don't immediately see what it would look like...

Thanks,
Rusty.
