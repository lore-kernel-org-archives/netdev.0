From: "Luis R. Rodriguez" <mcgrof@frijolero.org>
Subject: Re: [patch net-next]alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver
Date: Thu, 20 Oct 2011 13:33:57 -0700
Message-ID: <CAB=NE6W6Gc+dN3SzX00VwO9iheemNzhRQ34KuvMtZsBqVJQhJQ@mail.gmail.com>
References: <1319093184-19696-1-git-send-email-cloud.ren@Atheros.com>
 <20111020.044541.970282389722164761.davem@davemloft.net> <6349D7A510622448B1BA0967850A8438011CC21D@nasanexd02d.na.qualcomm.com>
 <20111020.052506.373437241768777548.davem@davemloft.net> <6349D7A510622448B1BA0967850A8438011CC2A0@nasanexd02d.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Ren, Cloud" <cjren@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6349D7A510622448B1BA0967850A8438011CC2A0@nasanexd02d.na.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2011 at 2:48 AM, Ren, Cloud <cjren@qca.qualcomm.com> wr=
ote:
>
>>From: "Ren, Cloud" <cjren@qca.qualcomm.com>
>>Date: Thu, 20 Oct 2011 09:23:07 +0000
>>
>>> As you saw, should I do the two following steps?
>>> 1. I firstly try to submit code to linux-staging.git.
>>> 2. After the driver have been accepted by =C2=A0linux-staging.git, =
I submit to net-
>>next.git again.
>>
>>You submit and get it into staging so that it can sit there for some =
time and get
>>reviewed and improved by others.
>>
>>One doesn't submit directly to net-next right after it gets into stag=
ing, staging
>>is a place where your driver lives while it still smelly funky and ne=
eds more
>>work.
>
> The driver will support the next generation NICs of Atheros. Meanwhil=
e, the driver can
> also have better optimization for AR8131 and AR8151 than atl1c. For s=
ome reason, we
> don't plan to patch atl1c driver to support our new NIC, such as AR81=
61. So I hope the driver
> can stay in net-next in the end. Of course, I will be responsible for=
 modify source code and
> let it match kernel requirements.

Cloud,

If you want to skip staging (which I recommend) then you need to
address all upstream concerns expressed. Given that you indicate that
you will be working on following up with the driver until its
acceptable upstream my recommendation is either to clean up the driver
very well and review it internally at Atheros prior to a public
submission *or* just dump into staging and get the benefit of
community cleanup and eventually wait until it is ready for proper
upstream. If you want internal private review at Atheros you can use
the internal private ath9k-devel list.

Also are you going to maintain the older atlx drivers? While at it can
you clear up who maintains what as far as Atheros is concerned for
Ethernet?

  Luis
