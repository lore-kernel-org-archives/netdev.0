From: "David S. Miller" <davem@redhat.com>
Subject: Re: route cache DoS testing and softirqs
Date: Tue, 30 Mar 2004 13:30:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040330133000.098761e2.davem@redhat.com>
References: <20040329222926.GF3808@dualathlon.random>
	<200403302005.AAA00466@yakov.inr.ac.ru>
	<20040330211450.GI3808@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, dipankar@in.ibm.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se, paulmck@us.ibm.com,
        akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: <20040330211450.GI3808@dualathlon.random>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Mar 2004 23:14:50 +0200
Andrea Arcangeli <andrea@suse.de> wrote:

> > There are no hardirqs in the case under investigation, remember?
> 
> no hardirqs? there must be tons of hardirqs if ksoftirqd never runs.

NAPI should be kicking in for this workload, and I know for a fact it is
for Robert's case.  There should only be a few thousand hard irqs per
second.

Until the RX ring is depleted the device's hardirqs will not be re-
enabled.
