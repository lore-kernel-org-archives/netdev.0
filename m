From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.25-rc2-mm1 - several bugs and a crash
Date: Fri, 22 Feb 2008 09:09:08 -0800
Message-ID: <20080222170908.GA9386@linux.vnet.ibm.com>
References: <20080216002522.9c4bd0fb.akpm@linux-foundation.org> <47BC982C.7050402@imap.cc> <47BD6072.4000407@trash.net> <47BE1A03.30300@imap.cc> <47BE1CE5.1030001@imap.cc>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47BE1CE5.1030001@imap.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 22, 2008 at 01:52:53AM +0100, Tilman Schmidt wrote:
> Am 22.02.2008 01:40 schrieb Tilman Schmidt:
> >>
> >>     [NETFILTER]: nf_conntrack: fix smp_processor_id() in preemptible code warning
> > 
> > Yes, it does; and the system also survives substantially longer.
> > (IOW, it hasn't crashed on me so far.)
> 
> Which of course it did the second after I sent off that mail. :-(
> No message at all this time at the time of the crash, even though
> I had "tail -f /var/log/messages" running in an ssh session.
> 
> So the nf_conntrack BUG is fixed, but the crash (and of course the
> swapper "spinlock bad magic" BUG) persists.

Do you have CONFIG_DEBUG_PREEMPT set?  That would help find any other
bugs similar to nf_conntrack.

							Thanx, Paul
