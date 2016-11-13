From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] ip6_output: ensure flow saddr actually
	belongs to device
Date: Sun, 13 Nov 2016 13:39:15 -0700
Message-ID: <61deca9c-2518-1fbf-c2b4-11d410acc73a@cumulusnetworks.com>
References: <CAHmME9qYYU-p5BhR0ReNSB+__wysuDK+eEk1SisCoyf4=2woxg@mail.gmail.com>
 <20161113132347.17907-1-Jason@zx2c4.com>
 <405b2e79-854d-4c30-07b0-bd524137d2f6@cumulusnetworks.com>
 <CAHmME9rV_Qqj_QNKOARav6vOyyF-__E07saChPYo9MF6wED83A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
 Hannes Frederic Sowa <hannes@stressinduktion.org>,
 LKML <linux-kernel@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <CAHmME9rV_Qqj_QNKOARav6vOyyF-__E07saChPYo9MF6wED83A@mail.gmail.com>
List-Unsubscribe: <http://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <http://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

On 11/13/16 1:19 PM, Jason A. Donenfeld wrote:
> I gave v2 my best shot. Hopefully it's adequate, but I have a feeling
> it might be best for you to just code up what you have in mind.

nah, you are doing fine. one more comment on v2.
