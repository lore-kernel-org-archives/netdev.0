From: David Miller <davem@davemloft.net>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Wed, 07 Dec 2016 14:52:40 -0500 (EST)
Message-ID: <20161207.145240.1636297838792223189.davem@davemloft.net>
References: <CAA93jw7hcmkcyD=t4VRrQFfHk+n+EkSVgY6KFDq0_-DGpMADYw@mail.gmail.com>
 <20161207.135127.789629809982860453.davem@davemloft.net>
 <CAHmME9oLgjDA2F0gkFzHU2Es8-XCxQHRABS18OKF0EnZgt1=LQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wireguard@lists.zx2c4.com,
 linux-kernel@vger.kernel.org, linux-mips@linux-mips.org
To: Jason@zx2c4.com
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <CAHmME9oLgjDA2F0gkFzHU2Es8-XCxQHRABS18OKF0EnZgt1=LQ@mail.gmail.com>
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

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Wed, 7 Dec 2016 19:54:12 +0100

> On Wed, Dec 7, 2016 at 7:51 PM, David Miller <davem@davemloft.net> wrote:
>> It's so much better to analyze properly where the misalignment comes from
>> and address it at the source, as we have for various cases that trip up
>> Sparc too.
> 
> That's sort of my attitude too, hence starting this thread. Any
> pointers you have about this would be most welcome, so as not to
> perpetuate what already seems like an issue in other parts of the
> stack.

The only truly difficult case to handle is GRE encapsulation.  Is
that the situation you are running into?

If not, please figure out what the header configuration looks like
in the case that hits for you, and what the originating device is
just in case it is a device driver issue.

Thanks.
