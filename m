From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [REGRESSION] tcp/ipv4: kernel panic because of (possible)
 division by zero
Date: Sun, 10 Jan 2016 13:00:51 -0500
Message-ID: <CADVnQynxoj7gvBhobhWaEQ2Fe-vzjarmdQ3NGQ9Eqs3JZqk4hw@mail.gmail.com>
References: <26396443.iDTTxgChSj@spock>
	<1562805.Wa36G0OKaZ@spock>
	<CADVnQykPOVf7PoK8-6Mvbmbcpe1eYY=cfKHgiNGDNSFfCDPb-A@mail.gmail.com>
	<8327163.i61PEGGqZy@spock>
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
In-Reply-To: <8327163.i61PEGGqZy@spock>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2016 at 12:50 PM, Oleksandr Natalenko
<oleksandr@natalenko.name> wrote:
> Haven't you missed "return ssthresh;" statement?

Yes, sorry. You'd clearly need to return ssthresh as well. :-)

neal
