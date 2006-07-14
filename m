From: paul.moore@hp.com
Subject: [PATCH 0/7] Latest NetLabel patch for 2.6.19
Date: Fri, 14 Jul 2006 14:57:39 -0400
Message-ID: <20060714185739.780700000@flek.zko.hp.com>
Cc: davem@davemloft.net, sds@epoch.ncsc.mil, jmorris@redhat.com,
	pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:20670 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1161290AbWGNS7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 14:59:15 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am posting this patchset for consideration and inclusion into the 2.6.19
kernel, it is against 2.6.18-rc1.

This patchset introduces NetLabel, a implementation of explicit packet
labeling (i.e. CIPSO), to the Linux kernel.  NetLabel has been designed to
have as minimal an impact on the base networking stack as possible; this
includes both code changes as well as performance.  I, as well as many others
who have posted to various lists on earlier NetLabel patches, believe that an
interoperable form of labeled networking is important for Linux's success in
the Trusted OS arena currently being dominated by commercial UNIX systems.
DaveM, I know you have previously posted that you feel CIPSO does not belong
in the Linux kernel on principle, however, I'm hoping the arguments posted
in response have softened your position ...

Earlier versions of this patchset have been posted to the netdev, SELinux,
LSM and RH-LSPP mailing lists over the past couple of months.  It now contains
several rounds of comments and has been tested on a variety of architectures
by people on the RH-LSPP mailing list over the course of the last several
weeks.

If accepted into the mainline kernel, both HP and myself pledge to maintain
this code.

 - Notes on Performance

This past week there was a thread on the RH-LSPP list where the performance of
the NetLabel patch was measured and discussed using the 2.6.17 kernel.  A copy
of the discussion can be found here:

 * http://www.redhat.com/archives/redhat-lspp/2006-July/msg00063.html

With the conclusion being that performance should not be an issue.

Unfortunately the vanilla 2.6.18-rc1 kernel has problems on the two machines
I use for performance testing so I am not currently able to update the
NetLabel performance numbers for 2.6.18-rc1.

 - Notes on Interoperability Testing

The NetLabel CIPSO implementation has been tested against Trusted Solaris and
HP-UX CMW without problems.

 - Instructions for Testing

For those of you wishing to test this patchset you will need the latest
release of the netlabel_tools tarball found here:

 * http://free.linux.hp.com/~pmoore/projects/linux_cipso

You also may want to make use of the "toy policy module" for SELinux which has
been posted to the RH-LSPP mailing list, the archived message can be found
here:

 * http://www.redhat.com/archives/redhat-lspp/2006-June/msg00243.html

Thanks.

--
paul moore
linux security @ hp
