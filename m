From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: updated: kvm networking todo wiki
Date: Thu, 30 May 2013 16:48:29 +0930
Message-ID: <87fvx5kkai.fsf@rustcorp.com.au>
References: <20130523085034.GA16142@redhat.com> <519F35B7.6010408@redhat.com>
	<20130524113542.GA7046@redhat.com> <8738tctrox.fsf@codemonkey.ws>
	<20130524140024.GA12024@redhat.com>
	<87li6yodgq.fsf@rustcorp.com.au> <87k3miq6sw.fsf@codemonkey.ws>
	<87r4gpkplc.fsf@rustcorp.com.au>
	<CAJSP0QWY3z_oGaHNwR0=whYgnDCiGLBC+3Z5oM0x5nwN1RQVqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm <kvm@vger.kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, qemu-devel <qemu-devel@nongnu.org>,
	Linux Virtualization <virtualization@lists.linux-foundation.org>,
	herbert@gondor.hengli.com.au, Anthony Liguori <anthony@codemonkey.ws>
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAJSP0QWY3z_oGaHNwR0=whYgnDCiGLBC+3Z5oM0x5nwN1RQVqg@mail.gmail.com>
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

Stefan Hajnoczi <stefanha@gmail.com> writes:
> On Thu, May 30, 2013 at 7:23 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
>> On the receive side, what can we do better than readv?  If we need to
>> return to userspace to tell the guest that we've got a new packet, we
>> don't win on latency.  We might reduce syscall overhead with a
>> multi-dimensional readv to read multiple packets at once?
>
> Sounds like recvmmsg(2).

Wow... the future is here, today!

Thanks,
Rusty.
