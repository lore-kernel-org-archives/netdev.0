From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: [atl2] warn_slowpath in dev_watchdog
Date: Sun, 18 Jan 2009 11:58:58 -0600
Message-ID: <20090118115858.1b636b2d@osprey.hogchain.net>
References: <gkt97e$ti0$1@ger.gmane.org>
	<20090117194045.649f55a0@osprey.hogchain.net>
	<767752.95325.qm@web110601.mail.gq1.yahoo.com>
	<20090118095231.2c73c448@osprey.hogchain.net>
	<879024.62535.qm@web110609.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Chris Snook <csnook@redhat.com>,
	jie.yang@atheros.com, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Sitsofe Wheeler <sitsofe@yahoo.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934644AbZARR7Q@vger.kernel.org>
In-Reply-To: <879024.62535.qm@web110609.mail.gq1.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 18 Jan 2009 09:40:15 -0800 (PST)
Sitsofe Wheeler <sitsofe@yahoo.com> wrote:


> [  125.684886] atl2: eth0 NIC Link is Down
> [  127.459033] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
> [  148.170925] atl2: eth0 NIC Link is Down
> [  149.736346] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
> [  199.704086] ------------[ cut here ]------------
> [  199.704095] WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x22b/0x240()
> [  199.704101] NETDEV WATCHDOG: eth0 (atl2): transmit timed out

Thanks Sitsofe.  This is what I was looking for.

I'll wait for you to try the patch I sent earlier.  I'd like to see if
the watchdog timeout occurs with the patch applied.

Thanks again,
Jay
