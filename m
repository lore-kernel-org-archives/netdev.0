From: "James R. Leu" <jleu@mindspring.com>
Subject: Re: Linux kernel updates and ip_crossover patch
Date: Thu, 30 Oct 2003 12:17:30 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031030181654.GA1474@mindspring.com>
References: <OF5B9BCA99.0441857B-ON65256DCF.004761FF-65256DCF.004828A5@in.ibm.com> <20031030095312.6ef82ff7.davem@redhat.com>
Reply-To: jleu@mindspring.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mehulkumar J Patel <mehul.patel@in.ibm.com>, olh@suse.de,
        aprasad@in.ibm.com, kaena@us.ibm.com, mfrueh@suse.de, olaf@suse.de,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031030095312.6ef82ff7.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I agree with David that this patch has a very narrow scope.  I think a
more generic solution for a virtualized IP stack would be used by many more
people, and still solve this specific problem.

I have a patch for 'virtualizing' the IPv4 stack for the 2.4 kernel
series.  I'm working on porting it to the 2.6 kernels and adding the
same functionality for IPv6.

If you're interested in checking out the 2.4 kernel patch you can get
the latest stable version from http://linux-vrf.sf.net/

That page also descibes howto get the most recent version from
my development tree.

-- 
James R. Leu
jleu@mindspring.com

On Thu, Oct 30, 2003 at 09:53:12AM -0800, David S. Miller wrote:
> On Thu, 30 Oct 2003 18:33:57 +0530
> Mehulkumar J Patel <mehul.patel@in.ibm.com> wrote:
> 
> > Basically we need IP CROSSOVER patch to be part of pseries kernel.
> 
> This is not how the Linux community works.  You don't say "hey, we
> _NEED_ this" and like magic it gets added to the Linux kernel.
> 
> Rather, it gets added because someone submits it and the community
> sees a need for the feature.
> 
> As networking maintainer what I see is that this feature is needed by
> and used by only a very small group of people for very specialized
> purposes.  Therefore there is no urgency to add this to the kernel
> sources any time soon.
> 
> You can continue whining, complaining about how much you personally
> _NEED_ the ip_crossover patch, but that isn't going to help you
> arrive at your goal.  Rather you should spend time explaining to
> the community what value it gives to them and why it would be useful
> to anything other than very specialized cases and uses.
