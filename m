From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: memory leak in gigaset_initcshw
Date: Thu, 04 Feb 2016 16:06:15 +0100
Message-ID: <1454598375.14366.72.camel@tiscali.nl>
References: <CACT4Y+Y+P7-pM0D4HTz4ZF6i+Rya22eOkPdnrv_OmDCMB7eQtg@mail.gmail.com>
	 <1454516189.14366.8.camel@tiscali.nl>
	 <1454526665.14366.22.camel@tiscali.nl>
	 <CACT4Y+aDi8L_GELzVv7QM8YdtMD7q-wH4uO7LhioeSvaEU5PJg@mail.gmail.com>
	 <1454591389.14366.49.camel@tiscali.nl>
	 <CACT4Y+aXo83LjyOjVG2ihyR94kex-z+=Of+x8o4i+0q8964-1g@mail.gmail.com>
	 <1454593604.14366.65.camel@tiscali.nl>
	 <CACT4Y+b2z0NHVPQbyYP1CA_80hXxhk+VOG6dzduMEsi+27Pi7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+b2z0NHVPQbyYP1CA_80hXxhk+VOG6dzduMEsi+27Pi7Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On do, 2016-02-04 at 15:54 +0100, Dmitry Vyukov wrote:
> One TIOCSETD is enough to trigger the leak.
> I've tested with different line disciplines and only N_GIGASET_M101
> triggers the leak.

So things appear to be just on my plate now. I'll see what I can come up
with. Feel free to prod me if I stay silent for too long.

Thanks for narrowing things down!


Paul Bolle
