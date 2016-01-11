From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [REGRESSION] tcp/ipv4: kernel panic because of (possible)
 division by zero
Date: Mon, 11 Jan 2016 13:47:08 -0500
Message-ID: <CADVnQynzxB7mFyprZnNzUUBNhtaibA+9LRGufDLjSw6QeZou2g@mail.gmail.com>
References: <26396443.iDTTxgChSj@spock>
	<1562805.Wa36G0OKaZ@spock>
	<CADVnQykPOVf7PoK8-6Mvbmbcpe1eYY=cfKHgiNGDNSFfCDPb-A@mail.gmail.com>
	<3240923.Qg3kfz0Bvr@spock>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>
To: Oleksandr Natalenko <oleksandr@natalenko.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3240923.Qg3kfz0Bvr@spock>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2016 at 4:56 PM, Oleksandr Natalenko
<oleksandr@natalenko.name> wrote:
> OK, it seems the assumption about YeAH is correct. Here is stacktrace fired by
> WARN_ON_ONCE():
>
> https://gist.github.com/851cedcfca60d6120035
>
> Is there sufficient info for you to prepare upstream patch?

Great. Thanks for running that test! Yes, I think that's enough info.
We sent a proposed upstream patch here:

  http://patchwork.ozlabs.org/patch/566072/
  tcp_yeah: don't set ssthresh below 2

Feel free to add your "Tested-By" to the thread if you have a chance
to test that patch.

Thanks,
neal
