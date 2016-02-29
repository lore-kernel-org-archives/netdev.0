From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 29 Feb 2016 08:24:23 -0800
Message-ID: <1456763063.648.78.camel@edumazet-ThinkPad-T530>
References: <56D1E8B6.6090003@hurleysoftware.com>
	 <1456638957.3676.12.camel@gmail.com>
	 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
	 <1456721889.3488.67.camel@gmail.com> <56D45DAF.5070709@hurleysoftware.com>
	 <1456760443.3488.151.camel@gmail.com> <56D46AB4.6060805@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56D46AB4.6060805@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On lun., 2016-02-29 at 07:58 -0800, Peter Hurley wrote:

> All that's happened is the first loop of NET_RX softirq has woken a
> process; that is sufficient to abort softirq and defer it for ksoftirqd.
> 
> That's why I'm saying this is a priority inversion, and one that
> will happen a lot.

Sure. This will happen every time ksoftirqd is launched.

Get rid of ksoftirqd or renice it so that you can easily be killed by
softirq storm.
