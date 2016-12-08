From: David Miller <davem@davemloft.net>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Thu, 08 Dec 2016 18:14:53 -0500 (EST)
Message-ID: <20161208.181453.1681964885150767592.davem@davemloft.net>
References: <CAHmME9qxz6wcOZuurqahXeY6QSF=zz0gH7gY4RZujLAJPNSWBA@mail.gmail.com>
 <20161207.193716.50344961208535056.davem@davemloft.net>
 <CAHmME9qGoPGEFyqe0jBaZD5R51wHTEgAYb9edj+nu9nNPWSYCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wireguard@lists.zx2c4.com,
 linux-kernel@vger.kernel.org, linux-mips@linux-mips.org
To: Jason@zx2c4.com
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <CAHmME9qGoPGEFyqe0jBaZD5R51wHTEgAYb9edj+nu9nNPWSYCA@mail.gmail.com>
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
Date: Thu, 8 Dec 2016 23:20:04 +0100

> Hi David,
> 
> On Thu, Dec 8, 2016 at 1:37 AM, David Miller <davem@davemloft.net> wrote:
>> You really have to land the IP header on a proper 4 byte boundary.
>>
>> I would suggest pushing 3 dummy garbage bytes of padding at the front
>> or the end of your header.
> 
> Are you sure 3 bytes to get 4 byte alignment is really the best? I was
> thinking that adding 1 byte to get 2 byte alignment might be better,
> since it would then ensure that the subsequent TCP header winds up
> being 4 byte aligned. Or is this in fact not the desired trade off,
> and so I should stick with the 3 bytes you suggested?

If the IP header is 4 byte aligned, the TCP header will be as well.
