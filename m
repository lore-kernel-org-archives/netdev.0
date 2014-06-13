From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 12 Jun 2014 23:48:57 -0700
Message-ID: <CA+55aFy=CThoSKAJ6J3Jt-SJDkiGzwg=5tdF7_g+vyTEoPFzMQ@mail.gmail.com>
References: <20140612.121445.484288603919840829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Intel Linux Wireless <ilw@linux.intel.com>
To: David Miller <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140612.121445.484288603919840829.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 12, 2014 at 12:14 PM, David Miller <davem@davemloft.net> wrote:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master

Hmm. I get *lots* of the appended messages from iwlwifi now. Things
still seem to work, but ...

This is a Haswell laptop with bog-standard intel wireless:

  01:00.0 Network controller: Intel Corporation Wireless 7260 (rev 6b)

Any ideas?

            Linus

---
[  273.783438] <unknown>: hw csum failure
[  273.783449] CPU: 2 PID: 2199 Comm: Chrome_IOThread Not tainted
3.15.0-11906-g6d87c225f5d8 #8
[  273.783451] Hardware name: Sony Corporation SVP11213CXB/VAIO, BIOS
R0270V7 05/17/2013
[  273.783461] Call Trace:
[  273.783477]  [<ffffffff8159d199>] ? dump_stack+0x41/0x51
[  273.783488]  [<ffffffff814a4f1d>] ?
skb_copy_and_csum_datagram_iovec+0xfd/0x110
[  273.783494]  [<ffffffff8150e2ea>] ? udp_recvmsg+0x1ca/0x390
[  273.783500]  [<ffffffff81518e95>] ? inet_recvmsg+0x65/0x80
[  273.783506]  [<ffffffff814971f5>] ? sock_recvmsg+0x95/0xd0
[  273.783511]  [<ffffffff81197862>] ? ep_send_events_proc+0xa2/0x1b0
[  273.783513]  [<ffffffff811977c0>] ? ep_read_events_proc+0xb0/0xb0
[  273.783516]  [<ffffffff81497325>] ? SYSC_recvfrom+0xb5/0x110
[  273.783521]  [<ffffffff8108bdc0>] ? wake_up_state+0x10/0x10
[  273.783527]  [<ffffffff815a3d92>] ? system_call_fastpath+0x16/0x1b
