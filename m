From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Automated linux kernel testing results
Date: Fri, 03 Jun 2005 17:20:04 -0700
Message-ID: <42A0F3B4.1060601@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For those who don't read lkml, I thought I'd point to
Martin Bligh's post regarding automated testing being
set up, since some people on this list were interested.

http://marc.theaimsgroup.com/?l=linux-kernel&m=111775021327595&w=2

Networking tests are in plan...

thanks,
Nivedita

--------------------------

OK, I've finally got this to the point where I can publish it.

http://ftp.kernel.org/pub/linux/kernel/people/mbligh/abat/regression_matrix.html


Currently it builds and boots any mainline, -mjb, -mm kernel within
about 15 minutes of release. runs dbench, tbench, kernbench, reaim and fsx.
Currently I'm using a 4x AMD64 box, a 16x NUMA-Q, 4x NUMA-Q, 32x x440
(ia32)
PPC64 Power 5 LPAR, PPC64 Power 4 LPAR, and PPC64 Power 4 bare metal
system.
The config files it uses are linked by the machine names in the column
headers.

Thanks to all the other IBM people who've worked on the ABAT test system
that this stuff relies on - too many to list, but especially Andy, Adam,
and Enrique, who have fixed endless bugs, and put up with my incessant
bitching about it all not working as it should ;-)

Clicking on the failure ones error codes should take you to somewhere
vaguely helpful to diagnose it. Clicking on the job number just below
that takes you to the info I'm publishing right now, which should
include perf results and profiles, etc. I'll add graphs, etc later,
comparing performance across kernels (I have them ... just not automated).
