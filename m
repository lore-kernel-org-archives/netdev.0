From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/4] samples/bpf: Improve user experience
Date: Tue, 26 Apr 2016 13:09:12 +0200
Message-ID: <20160426110828.20716.13392.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bblanco@plumgrid.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com, linux-kbuild@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53954 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382AbcDZLJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 07:09:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a steep learning curve getting started with using the eBPF
examples in samples/bpf/.  There are several dependencies, and
specific versions of these dependencies.  Invoking make in the correct
manor is also slightly obscure.

This patchset cleanup, document and hopefully improves the first time
user experience with the eBPF samples directory by auto-detecting
certain scenarios.

---

Jesper Dangaard Brouer (4):
      samples/bpf: add back functionality to redefine LLC command
      samples/bpf: Makefile verify LLVM compiler avail and bpf target is supported
      samples/bpf: add a README file to get users started
      samples/bpf: allow make to be run from samples/bpf/ directory


 samples/bpf/Makefile   |   32 +++++++++++++++++++++-
 samples/bpf/README.rst |   70 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 101 insertions(+), 1 deletion(-)
 create mode 100644 samples/bpf/README.rst
