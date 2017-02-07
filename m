From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/4] Documenting eBPF - extended Berkeley Packet
 Filter
Date: Tue, 07 Feb 2017 15:30:11 +0100
Message-ID: <148647756092.10567.10947541548678801938.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, alexander@alemayhu.com,
        linux-kernel@vger.kernel.org, quentin.monnet@6wind.com,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>
To: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        Jonathan Corbet <corbet@lwn.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Question: What kernel tree should this go into???

If going through Jonathan Corbet, will it appear sooner here???
 https://www.kernel.org/doc/html/latest/
If it will not appear sooner that way, then it's likely best to keep
it in sync with the tree that takes eBPF code changes.


This marks the beginning of user-facing developer documentation for
using eBPF (extended Berkeley Packet Filter) as part of the kernel
Documentation/ tree.

This documentation is also available here[1], as an intermidiate quick
way of prototyping and releasing the documentation.  The autoriative
and official version of the documentation is what gets included in the
kernel tree.  The docs at [2] will get updated based on what gets
accepted after the standard peer-review kernel process.

[1] http://prototype-kernel.readthedocs.io/en/latest/bpf/index.html
[2] https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/Documentation

Thanks to the following people, who have already reviewed and fixed
earlier versions of this documentation on the IOvisor mailing-list:

 Alexander Alemayhu <alexander@alemayhu.com>
 Alexei Starovoitov <ast@fb.com>
 Daniel Borkmann <daniel@iogearbox.net>
 Quentin Monnet <quentin.monnet@6wind.com>


---

Jesper Dangaard Brouer (4):
      doc/bpf: start eBPF documentation tree bpf/
      doc/bpf: document interacting with eBPF maps
      doc/bpf: describes the different types of eBPF maps available
      doc/bpf: describe BCC the BPF Compiler Collection


 Documentation/bpf/bcc_tool_chain.rst  |   37 +++++
 Documentation/bpf/ebpf_maps.rst       |  256 +++++++++++++++++++++++++++++++++
 Documentation/bpf/ebpf_maps_types.rst |  119 +++++++++++++++
 Documentation/bpf/index.rst           |   68 +++++++++
 Documentation/index.rst               |    1 
 5 files changed, 481 insertions(+)
 create mode 100644 Documentation/bpf/bcc_tool_chain.rst
 create mode 100644 Documentation/bpf/ebpf_maps.rst
 create mode 100644 Documentation/bpf/ebpf_maps_types.rst
 create mode 100644 Documentation/bpf/index.rst

--
