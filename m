From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Wed, 07 Dec 2016 23:34:21 -0500
Message-ID: <87vauvhwdu.fsf@alice.fifthhorseman.net>
References: <CAHmME9o_eCNXpVztOZKW55kpRtE+1KSEQTQOjUBVn68Y2+or2g@mail.gmail.com>
 <095cac5b-b757-6f4a-e699-8eedf9ed7221@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
 "Jason A. Donenfeld" <Jason@zx2c4.com>, Netdev <netdev@vger.kernel.org>,
 linux-mips@linux-mips.org
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <095cac5b-b757-6f4a-e699-8eedf9ed7221@stressinduktion.org>
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

On Wed 2016-12-07 19:30:34 -0500, Hannes Frederic Sowa wrote:
> Your custom protocol should be designed in a way you get an aligned ip
> header. Most protocols of the IETF follow this mantra and it is always
> possible to e.g. pad options so you end up on aligned boundaries for the
> next header.

fwiw, i'm not convinced that "most protocols of the IETF follow this
mantra".  we've had multiple discussions in different protocol groups
about shaving or bloating by a few bytes here or there in different
protocols, and i don't think anyone has brought up memory alignment as
an argument in any of the discussions i've followed.

that said, it sure does sound like it would make things simpler to
construct the protocol that way :)

          --dkg
