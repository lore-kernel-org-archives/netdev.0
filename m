From: rapier <rapier@psc.edu>
Subject: Re: [Web10g-user] Web10g TCP statistics patch - mainlining into kernel?
Date: Fri, 25 Jan 2013 14:34:57 -0500
Message-ID: <5102DE61.80804@psc.edu>
References: <18855.1359138716@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: web10g-user@web10g.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <18855.1359138716@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

My name is Chris Rapier and I'm on the Web10G dev team. We are 
interested in moving this into consideration for the mainline Linux 
kernel, in fact it's the primary goal of this project. We haven't 
brought this to the linux kernel community as of yet as we've not 
completed the quantification of performance/memory impact versus a 
vanilla baseline as of yet. Including the KIS we also have to test the 
impact the DKLM imposes (taking into account measurement granularity, 
number of concurrent connections, maximum throughput for a single 
stream, etc). Then we need to compare that against Web100 and write a 
paper. We're looking at around a 2 month time frame for that.

That being said, we welcome any and all insight and help on this that we 
can get from the community. Our desire to get the tests and paper worked 
out before bringing it to the kernel community was to simply make sure 
we would be able to answer any questions that might come up. 
Additionally, if you have any metrics of the impact of the KIS, DKLM, or 
any combination thereof we'd love to see them. The more data the better 
(for some definitions of better).

I and the rest of the development team are more than happy to answer any 
questions, address concerns, explain our thinking, discuss possible 
applications for this data, etc with anyone interested.

The web100-user list is probably the best way (for us at least) to do 
this. You do need to subscribe to post at 
https://lists.psc.edu/mailman/listinfo/web10g-user but I'll do my best 
to add any relevant posts that get caught up in the filter.

Thanks for your interest and I look forward to talking to anyone 
interested in our work.

Chris Rapier
Pittsburgh Supercomputing Center



On 1/25/13 1:31 PM, Valdis Kletnieks wrote:
> I had a user who's working on tuning high-performance network file systems what
> the chances of upstreaming the Web10G patch to provide the RFC4898 TCP Extended
> Statistics MIB via netlink.
>
> Yes, it's a tad on the intrusive side, and there's performance costs attached -
> but so are a lot of *other* things that people use all the time for kernel
> debugging, and it's a zero-hit thing for people who don't choose to configure
> it into their kernel.  The added detailed status available from this will be
> useful for people who are doing tuning and development (consider how useful
> this would have been for the people who wrote the codel line discipline as part
> of the bufferbloat project).
>
> I'm willing to do the not-so-heavy lifting of getting the existing patch
> cleaned up to upstream standards and sheparded through the process, if there's
> any interest at all....
>
>
>
> _______________________________________________
> Web10g-user mailing list
> Web10g-user@web10g.org
> https://lists.psc.edu/mailman/listinfo/web10g-user
>
> To UNSUBSCRIBE visit https://lists.psc.edu/mailman/unsubscribe/web10g-user
>
