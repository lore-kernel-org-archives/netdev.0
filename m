From: "Luis R. Rodriguez" <mcgrof@frijolero.org>
Subject: Linux kernel backporting - moving forward
Date: Thu, 8 Mar 2012 14:08:24 -0800
Message-ID: <CAB=NE6VcFxfy_x050zJbJ0UJGoZTbgbh418mbJiSgYAX7nXNgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth <linux-bluetooth@vger.kernel.org>,
	Ubuntu Kernel Team <kernel-team@lists.ubuntu.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: lf_driver_backport@lists.linux-foundation.org,
	Till Kamppeter <till.kamppeter@gmail.com>, Julia Lawall <julia@diku.dk>,
	Jesper Andersen <jespera@diku.dk>
Return-path: <kernel-team-bounces@lists.ubuntu.com>
List-Unsubscribe: <https://lists.ubuntu.com/mailman/options/kernel-team>,
	<mailto:kernel-team-request@lists.ubuntu.com?subject=unsubscribe>
List-Archive: <https://lists.ubuntu.com/archives/kernel-team>
List-Post: <mailto:kernel-team@lists.ubuntu.com>
List-Help: <mailto:kernel-team-request@lists.ubuntu.com?subject=help>
List-Subscribe: <https://lists.ubuntu.com/mailman/listinfo/kernel-team>,
	<mailto:kernel-team-request@lists.ubuntu.com?subject=subscribe>
Sender: kernel-team-bounces@lists.ubuntu.com
Errors-To: kernel-team-bounces@lists.ubuntu.com
List-Id: netdev.vger.kernel.org

I'd like to start coordinating a bit better with other subsystem
backporting the Linux kernel and formalizing strategies for the long
run a bit better. I know the Linux Foundation has a work group for it
[0] but the archives show little activity. We have been doing backport
work for the 802.11 through compat-wireless [1] for a while now and
this project has evolved now to also include support for Bluetooth,
Ethernet drivers, and as of late we decided to split up the core
kernel components into a generic module and separate project [2] which
could be used by any kernel backport project. We also now have stable
backports of the Linux kernel [3]. The split of the framework to
backport a subsystem and to provide a generic module has proven quite
successful in terms of management of code. The split also has helped
better understand the problems required to properly backport pieces of
the Linux kernel and to also consider specific solutions for such
problems. Consider the research and work that Jesper Andersen & Julia
have done through a Generic Patch Interface [4] (spatch, spdiff), and
possible ways for us to use this to help backport. Those utilities and
ideas can better be considered for backporting the kernel after
breaking the problem statements down further and seeing where that
work is actually applicable.

What I'd like to propose is maintainers who do backport other
subsystems join the Linux Foundation list lf_driver_backport [5], and
we start sharing as much backport code through compat [2]. Later we
can hopefully see if we can share an framework for pulling code based
on linux-next.git as we do through the compat-wireless framework, but
I'd also like to ensure we prioritize working on upstream properly as
a unified objective to deal with extra patches as we have with
compat-wireless [6].

If any of you folks are gong to be at the LF collab summit I propose
we meet for beers and review some of this as well. I proposed a talk
for it but I do not think it went through.

Any opposition to start using the LF Driver Backport workgroup mailing
list for compat patches for now? I'd also start coordinating things a
bit better on the wiki.

[0] http://www.linuxfoundation.org/collaborate/workgroups/gsoc/2012-gsoc-driver-backports
[1] http://wireless.kernel.org/en/users/Download/
[2] http://mcgrof.github.com/compat/
[3] http://wireless.kernel.org/en/users/Download/stable/
[4] http://www.diku.dk/~julia/andersen_ase08.pdf
[5] http://lists.linux-foundation.org/mailman/listinfo/lf_driver_backport
[6] http://wireless.kernel.org/en/users/Download/stable/#Additional_patches_to_stable_releases

  Luis
