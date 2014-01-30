From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 0/2] [BUG FIXES - 3.10.27] sit: More backports
Date: Thu, 30 Jan 2014 08:31:03 -0500
Message-ID: <20140130083103.2bc68bad@gandalf.local.home>
References: <20140128205756.074448668@goodmis.org>
	<52E8E025.2060803@6wind.com>
	<20140129075745.4227a2ed@gandalf.local.home>
	<52E9267C.90403@6wind.com>
	<20140129154811.27fbaf13@gandalf.local.home>
	<52EA1B4B.5080403@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable <stable@vger.kernel.org>,
	Clark Williams <williams@redhat.com>,
	"Luis Claudio R. Goncalves" <lclaudio@uudg.org>,
	John Kacur <jkacur@redhat.com>,
	Willem de Bruijn <willemb@google.com>
To: nicolas.dichtel@6wind.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52EA1B4B.5080403@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Jan 2014 10:28:43 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:


> Steve, I think the patch I sent yesterday is the good fix. At the end, it's
> a backport of Willem's patch. Note that he also ack that patch.
> The first version you sent (which removes
> unregister_netdevice_queue(sitn->fb_tunnel_dev, &list)) will introduce a
> memory leak when the user destroy a netns.

Hi Nicolas,

I reverted my patches and applied and tested your patches locally and
they passed my first line testing. I'm going to have them entered into
our test suite, after removing our other patches, and see if they solve
all the bugs that we were tripping over.

I'll let you know when these are finished.

Thanks!

-- Steve
