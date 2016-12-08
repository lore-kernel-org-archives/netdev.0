From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Thu, 8 Dec 2016 23:20:04 +0100
Message-ID: <CAHmME9qGoPGEFyqe0jBaZD5R51wHTEgAYb9edj+nu9nNPWSYCA@mail.gmail.com>
References: <CAHmME9oLgjDA2F0gkFzHU2Es8-XCxQHRABS18OKF0EnZgt1=LQ@mail.gmail.com>
 <20161207.145240.1636297838792223189.davem@davemloft.net>
 <CAHmME9qxz6wcOZuurqahXeY6QSF=zz0gH7gY4RZujLAJPNSWBA@mail.gmail.com>
 <20161207.193716.50344961208535056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <20161207.193716.50344961208535056.davem@davemloft.net>
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

Hi David,

On Thu, Dec 8, 2016 at 1:37 AM, David Miller <davem@davemloft.net> wrote:
> You really have to land the IP header on a proper 4 byte boundary.
>
> I would suggest pushing 3 dummy garbage bytes of padding at the front
> or the end of your header.

Are you sure 3 bytes to get 4 byte alignment is really the best? I was
thinking that adding 1 byte to get 2 byte alignment might be better,
since it would then ensure that the subsequent TCP header winds up
being 4 byte aligned. Or is this in fact not the desired trade off,
and so I should stick with the 3 bytes you suggested?

Jason
