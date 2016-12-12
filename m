From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Mon, 12 Dec 2016 16:31:47 +0000
Message-ID: <yw1xd1gxw1l8.fsf@unicorn.mansr.com>
References: <CAHmME9o_eCNXpVztOZKW55kpRtE+1KSEQTQOjUBVn68Y2+or2g@mail.gmail.com>
 <CAA93jw7hcmkcyD=t4VRrQFfHk+n+EkSVgY6KFDq0_-DGpMADYw@mail.gmail.com>
 <20161207.135127.789629809982860453.davem@davemloft.net>
 <CAHmME9oLgjDA2F0gkFzHU2Es8-XCxQHRABS18OKF0EnZgt1=LQ@mail.gmail.com>
 <040bcdb2-2725-c8de-11d9-a4f77b75d9d8@nbd.name>
 <yw1x37hvykzk.fsf@unicorn.mansr.com>
 <063D6719AE5E284EB5DD2968C1650D6DB023BF78@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
 Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 David Miller <davem@davemloft.net>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 Felix Fietkau <nbd@nbd.name>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB023BF78@AcuExch.aculab.com>
 (David Laight's message of "Mon, 12 Dec 2016 16:19:17 +0000")
List-Unsubscribe: <https://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <https://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

David Laight <David.Laight@ACULAB.COM> writes:

> From: M=E5ns Rullg=E5rd
>> Sent: 10 December 2016 13:25
> ...
>> I solved this problem in an Ethernet driver by copying the initial part
>> of the packet to an aligned skb and appending the remainder using
>> skb_add_rx_frag().  The kernel network stack only cares about the
>> headers, so the alignment of the packet payload doesn't matter.
>
> That rather depends on where the packet payload ends up.
> It is likely that it will be copied to userspace (or maybe
> into some aligned kernel buffer).
> In which case you get an expensive misaligned copy.

There's not much to be done about that.  The only other option is to
bypass DMA entirely, and that's sure to be even worse.

> What do the hardware engineers think the ethernet interface will
> be used for!

Ticking boxes in marketing material.

-- =

M=E5ns Rullg=E5rd
