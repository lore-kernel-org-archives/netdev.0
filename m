From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [REGRESSION] tcp/ipv4: kernel panic because of (possible)
 division by zero
Date: Sun, 10 Jan 2016 09:54:16 -0500
Message-ID: <CADVnQykvDhCrCuFR0MCiEvD7DUbf+ZVBOysa1iWSE6-FydzqYQ@mail.gmail.com>
References: <26396443.iDTTxgChSj@spock>
	<CAK6E8=dSRmf35AaC6mOcRaGSxn81CE76WiOfNx6jb5X8uhDGqw@mail.gmail.com>
	<CAK6E8=chikkT02ygDHzHN9xP7q7kzWUqHEVgj7g0oW_RUPcuoA@mail.gmail.com>
	<8830013.bJO8vnIv9N@spock>
	<CADVnQy=S62KoQL7thY73Kb=1Qd60drvOHJhE8UwH9qzPFOadEg@mail.gmail.com>
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
In-Reply-To: <CADVnQy=S62KoQL7thY73Kb=1Qd60drvOHJhE8UwH9qzPFOadEg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2016 at 9:48 AM, Neal Cardwell <ncardwell@google.com> wrote:
> On Sun, Jan 10, 2016 at 5:23 AM, Oleksandr Natalenko
> <oleksandr@natalenko.name> wrote:
>> With the patch queued for upstream and ECN enabled I get WARN_ON_ONCE()
>> triggered. Here is the stacktrace:
>>
>> https://gist.github.com/89203e77bfcb051f269a
>>
>> It seems that tp->prior_cwnd is zero.
>
> Hmm. Interesting. Can you please confirm that you are using the cubic
> congestion control module?

Would you be able to do an experiment where you reboot, and then
disable ECN upon startup, and then see if the warning still shows up
without ECN?

thanks,
neal
