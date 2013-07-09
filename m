From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: put virtio net header inline with data
Date: Tue, 09 Jul 2013 17:38:51 +0930
Message-ID: <87vc4kcfzg.fsf@rustcorp.com.au>
References: <20130708101259.GA16074@redhat.com>
	<871u78eavc.fsf@rustcorp.com.au> <20130709051824.GA3234@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Dave Jones <davej@redhat.com>, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130709051824.GA3234@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> On Tue, Jul 09, 2013 at 11:46:23AM +0930, Rusty Russell wrote:
>> "Michael S. Tsirkin" <mst@redhat.com> writes:
>> > For small packets we can simplify xmit processing
>> > by linearizing buffers with the header:
>> > most packets seem to have enough head room
>> > we can use for this purpose.
>> > Since existing hypervisors require that header
>> > is the first s/g element, we need a feature bit
>> > for this.
>> >
>> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> > ---
>> >
>> > Note: this needs to be applied on top of patch
>> > defining VIRTIO_F_ANY_LAYOUT - bit to be
>> > selected by Rusty.
>> >
>> > The following patch should work for any definition of
>> > VIRTIO_F_ANY_LAYOUT - I used bit 31 for testing.
>> > Rusty, could you please pick a valid bit for VIRTIO_F_ANY_LAYOUT
>> > and squeeze this patch into 3.11?
>> 
>> Sorry, it's too late.
>> 
>> First, I've been a bit lax in sending patches via DaveM, and this is
>> definitely his territory (ie. more net than virtio).
>
> Let's do this: I'll send a patch series, you ack and we see
> what happens?

If you convince DaveM, I won't object :)

>> Secondly, it needs baking and testing time.
>> 
>> Cheers,
>> Rusty.
>
> I did some testing on this.  But proper testing just isn't happening out
> of tree.

But it will get into linux-next for the *next* merge window.

Cheers,
Rusty.
