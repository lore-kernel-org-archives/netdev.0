From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] Move to BPF selftests
Date: Mon, 17 Oct 2016 14:28:34 +0200
Message-ID: <cover.1476705709.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44075 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933453AbcJQM2z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 08:28:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set improves the test_verifier and test_maps suite and moves
it over to a new BPF selftest directory, so we can keep improving
it under kernel selftest umbrella. This also integrates a test
script for checking test_bpf.ko under various JIT options.

Thanks!

Daniel Borkmann (2):
  bpf: add various tests around spill/fill of regs
  bpf: add initial suite for selftests

 MAINTAINERS                                 |    3 +-
 samples/bpf/Makefile                        |    3 -
 samples/bpf/test_maps.c                     |  503 -----
 samples/bpf/test_verifier.c                 | 2529 ------------------------
 tools/include/linux/filter.h                |   24 +
 tools/testing/selftests/Makefile            |    3 +-
 tools/testing/selftests/bpf/.gitignore      |    2 +
 tools/testing/selftests/bpf/Makefile        |   13 +
 tools/testing/selftests/bpf/bpf_sys.h       |  108 ++
 tools/testing/selftests/bpf/config          |    5 +
 tools/testing/selftests/bpf/test_kmod.sh    |   39 +
 tools/testing/selftests/bpf/test_maps.c     |  525 +++++
 tools/testing/selftests/bpf/test_verifier.c | 2764 +++++++++++++++++++++++++++
 13 files changed, 3484 insertions(+), 3037 deletions(-)
 delete mode 100644 samples/bpf/test_maps.c
 delete mode 100644 samples/bpf/test_verifier.c
 create mode 100644 tools/testing/selftests/bpf/.gitignore
 create mode 100644 tools/testing/selftests/bpf/Makefile
 create mode 100644 tools/testing/selftests/bpf/bpf_sys.h
 create mode 100644 tools/testing/selftests/bpf/config
 create mode 100755 tools/testing/selftests/bpf/test_kmod.sh
 create mode 100644 tools/testing/selftests/bpf/test_maps.c
 create mode 100644 tools/testing/selftests/bpf/test_verifier.c

-- 
1.9.3
