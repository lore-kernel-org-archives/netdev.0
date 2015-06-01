From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] neighbour: Add loglevel to printk statment in the
 function, neigh_add_timer
Date: Mon, 1 Jun 2015 12:01:58 -0700
Message-ID: <CAM_iQpV3tHjq-f1fHXH3kefmzThyU4uCQ3JjyqrVcdGpLFA5TA@mail.gmail.com>
References: <1433131982-13697-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, jeff@melix.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433131982-13697-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 31, 2015 at 9:13 PM, Nicholas Krause <xerofoify@gmail.com> wrote:
> This makes the printk statement in the function, neigh_add_timer
> have a loglevel of KERN_CRIT in order to get printed with the
> dumping of the stack if a double timer add arises rather then
> get dumped into the syslog buffer file instead in order to
> allow developers to see why a stack dump has arisen.
>

Instead, why not just use a WARN_ON() or something like that?
