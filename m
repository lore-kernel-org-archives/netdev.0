From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v4 0/3] Miscellaneous fixes for BPF (perf tree)
Date: Wed,  8 Feb 2017 21:27:41 +0100
Message-ID: <20170208202744.16274-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, Wang Nan <wangnan0@huawei.com>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh2.infomaniak.ch ([128.65.195.6]:38031 "EHLO
        smtp-sh2.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdBHUa1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 15:30:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series brings some fixes and small improvements to the BPF samples.

This is intended for the perf tree and apply on 7a5980f9c006 ("tools lib bpf:
Add missing header to the library").

Changes since v3:
* remove applied patch 1/5
* remove patch 2/5 on bpf_load_program() as requested by Wang Nan

Changes since v2:
* add this cover letter

Changes since v1:
* exclude patches not intended for the perf tree

Regards,

Mickaël Salaün (3):
  samples/bpf: Ignore already processed ELF sections
  samples/bpf: Reset global variables
  samples/bpf: Add missing header

 samples/bpf/bpf_load.c     | 7 +++++++
 samples/bpf/tracex5_kern.c | 1 +
 2 files changed, 8 insertions(+)

-- 
2.11.0
