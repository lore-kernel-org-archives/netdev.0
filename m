From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [FAILED COMPILE v4.3-rc2] conntrack.c:316: undefined reference
 to `nf_ct_frag6_gather'
Date: Tue, 22 Sep 2015 18:42:54 -0400
Message-ID: <20150922184254.51bf618f@gandalf.local.home>
References: <20150922180517.6e928292@gandalf.local.home>
	<CANr6G5y92P17C7kzJVyF3GNO-Tprq79NzMPpHf_8WsPQPYOqiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Justin Pettit <jpettit@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANr6G5y92P17C7kzJVyF3GNO-Tprq79NzMPpHf_8WsPQPYOqiQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Sep 2015 15:16:27 -0700
Joe Stringer <joestringer@nicira.com> wrote:

> On 22 September 2015 at 15:05, Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> > The attached config gives the following error:
> >
> > net/built-in.o: In function `handle_fragments':
> > net/openvswitch/conntrack.c:316: undefined reference to `nf_ct_frag6_gather'
> > Makefile:916: recipe for target 'vmlinux' failed
> >
> > -- Steve
> 
> commit 38c089d "openvswitch: Fix dependency on IPv6 defrag." on dave's
> net tree fixes this.

OK, thanks! I'll add it to my "fixes" patch queue for my tests.

-- Steve
