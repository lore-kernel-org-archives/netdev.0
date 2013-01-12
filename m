From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFCv2 00/12] Introduce host-side virtio queue and CAIF Virtio.
Date: Sat, 12 Jan 2013 10:50:30 +1030
Message-ID: <874nin1cc1.fsf@rustcorp.com.au>
References: <871ug75vp1.fsf@rustcorp.com.au>
	<1354718230-4486-1-git-send-email-sjur@brendeland.net>
	<20121206102750.GF10837@redhat.com>
	<877goc0wac.fsf@rustcorp.com.au>
	<CAJK669bP41oBhJ=MB64NS21Ag7XO5WswuTiVKCFTb96nvmyBiw@mail.gmail.com>
	<87pq1f2rj0.fsf@rustcorp.com.au> <87wqvl1g9s.fsf@rustcorp.com.au>
	<20130110111117.GE13451@redhat.com>
	<87sj681wou.fsf@rustcorp.com.au>
	<20130111073155.GA13315@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linus Walleij <linus.walleij@linaro.org>,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130111073155.GA13315@redhat.com>
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
> On Fri, Jan 11, 2013 at 09:18:33AM +1030, Rusty Russell wrote:
>> "Michael S. Tsirkin" <mst@redhat.com> writes:
>> > On Thu, Jan 10, 2013 at 09:00:55PM +1030, Rusty Russell wrote:
>> >> Not sure why vhost/net doesn't built a packet and feed it in
>> >> netif_rx_ni().  This is what tun seems to do, and with this code it
>> >> should be fairly optimal.
>> >
>> > Because we want to use NAPI.
>> 
>> Not quite what I was asking; it was more a question of why we're using a
>> raw socket, when we trivially have a complete skb already which we
>> should be able to feed to Linux like any network packet.
>
> Oh for some reason I thought you were talking about virtio.
> I don't really understand what you are saying here - vhost
> actually calls out to tun to build and submit the skb.

Ah, the fd is tun?  Seems a bit indirect; I wonder if there's room for
more optimization here...

Cheers,
Rusty.
