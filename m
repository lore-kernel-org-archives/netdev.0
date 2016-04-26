From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 0/5] samples/bpf: Improve user experience
Date: Tue, 26 Apr 2016 18:27:06 +0200
Message-ID: <20160426162650.22962.20516.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org, bblanco@plumgrid.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	naveen.n.rao@linux.vnet.ibm.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49402 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751966AbcDZQ1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 12:27:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a steep learning curve getting started with using the eBPF
examples in samples/bpf/.  There are several dependencies, and
specific versions of these dependencies.  Invoking make in the correct
manor is also slightly obscure.

This patchset cleanup, document and hopefully improves the first time
user experience with the eBPF samples directory by auto-detecting
certain scenarios.

V2:
 - Adjusted recommend minimum versions to 3.7.1
 - Included clang build instructions
 - New patch adding CLANG variable and validation of command

---

Jesper Dangaard Brouer (5):
      samples/bpf: add back functionality to redefine LLC command
      samples/bpf: Makefile verify LLVM compiler avail and bpf target is supported
      samples/bpf: add a README file to get users started
      samples/bpf: allow make to be run from samples/bpf/ directory
      samples/bpf: like LLC also verify and allow redefining CLANG command


 samples/bpf/Makefile   |   37 +++++++++++++++++++++-
 samples/bpf/README.rst |   80 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 115 insertions(+), 2 deletions(-)
 create mode 100644 samples/bpf/README.rst
