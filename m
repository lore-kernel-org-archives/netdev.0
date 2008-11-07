From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Network performance forwarding tests on RT
Date: Fri, 7 Nov 2008 08:52:10 -0800
Message-ID: <20081107085210.67d4c962@extreme>
References: <20081105115205.14c5282f@s6510>
	<20081106185029.0d4c5cd8@redhat.com>
	<ccb913ac0811062303r7f94f8a8lfe48336d6dafb9f6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Clark Williams" <williams@redhat.com>,
	linux-rt-users@vger.kernel.org, netdev@vger.kernel.org
To: "Tobias Knutsson" <tobias.knutsson@gmail.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <ccb913ac0811062303r7f94f8a8lfe48336d6dafb9f6@mail.gmail.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 7 Nov 2008 08:03:44 +0100
"Tobias Knutsson" <tobias.knutsson@gmail.com> wrote:

> First off all, let me just say than I am relatively new to PREEMPT_RT and I
> have no experience with Vyatta. It is just that some thoughts came to me
> that might be useful to consider.
> 
> What priorities does the network related threads have? There should be one
> for the ISR and one each for the soft irq responsible for the receiving and
> transmitting of network data. Maybe adjusting some of these priorities could
> improve the situation.

What ever the default is, nothing was changed.

Remember for this test there really is no application activity. Only the hard irq
threads of the Ethernet device, and the soft irq threads from the network
scheduler (NAPI).  I made the assumption that default priority is set
to allow such that hard irq > soft irq.
