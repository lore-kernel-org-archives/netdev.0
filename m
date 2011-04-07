From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [net-next-2.6] Revert "net: Allow no-cache copy from user on transmit"
Date: Thu, 7 Apr 2011 13:03:08 +0200
Message-ID: <BANLkTi=GFbgwV_7XJAJgKrY6A6J8-4FAdQ@mail.gmail.com>
References: <BANLkTim5Yv2Ekg1yXQy-8KZfS=hF0i2+2Q@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Jesse Gross <jesse@nicira.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Kees Cook <kees.cook@canonical.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-next <linux-next@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <BANLkTim5Yv2Ekg1yXQy-8KZfS=hF0i2+2Q@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

...will try the patch from [1]:

- Sedat -

[1] http://marc.info/?l=linux-netdev&m=130215119417648&w=2

On Thu, Apr 7, 2011 at 12:49 PM, Sedat Dilek <sedat.dilek@googlemail.com> wrote:
> [ The long CC list I got via ./scripts/get_maintainer.pl ]
>
> Hi,
>
> with yesterday's linux-next (next-20110406) I discovered first time
> network problems.
> Today's next-20110407 shows the same symptoms.
> In my IRC client the connection via SSL-encryption to freenode and
> oftc are not established.
> Also, I saw "stalls" on websites in firefox.
>
> Luckily, next-20110405 was OK, so I started to look at the
> net-next-2.6 merge and its commits.
> ( Furthermore, I tested a 2.6.39-rc2 vanilla kernel to ensure the
> problem comes from linux-next patch. )
>
> By reverting all 10 commits my system worked as expected, here the list:
>
> 0001-Revert-net-Allow-no-cache-copy-from-user-on-transmit.patch
> 0002-Revert-bridge-range-check-STP-parameters.patch
> 0003-Revert-bridge-allow-creating-bridge-devices-with-net.patch
> 0004-Revert-bridge-allow-creating-deleting-fdb-entries-vi.patch
> 0005-Revert-bridge-add-netlink-notification-on-forward-en.patch
> 0006-Revert-bridge-split-rcu-and-no-rcu-cases-of-fdb-look.patch
> 0007-Revert-bridge-track-last-used-time-in-forwarding-tab.patch
> 0008-Revert-bridge-change-arguments-to-fdb_create.patch
> 0009-Revert-pkt_sched-QFQ-quick-fair-queue-scheduler.patch
> 0010-Revert-xen-netfront-assume-all-hw-features-are-avail.patch
>
> In a next run, I started with only
> "0001-Revert-net-Allow-no-cache-copy-from-user-on-transmit.patch".
> It turned out that this is the culprit commit.
> ( I have not played with the new ethtool option tx-nocache-copy in
> "BROKEN" kernel. )
>
> My wificard is an Atheros ath5k.
> I attached my kernel-config and the revert-patch which makes the
> system stable again.
>
> Can you have a look at it?
>
> I you want me to help with debugging, please give me precise instructions.
>
> Regards,
> - Sedat -
>
