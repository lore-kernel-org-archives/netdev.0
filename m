From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH net-next 0/3] Misc BPF cleanup
Date: Mon, 24 Apr 2017 15:31:05 +0200
Message-ID: <20170424133108.31595-1-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Alexander Alemayhu <alexander@alemayhu.com>, daniel@iogearbox.net,
        ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:34956 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1171341AbdDXNbV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 09:31:21 -0400
Received: by mail-lf0-f41.google.com with SMTP id 75so73829059lfs.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 06:31:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hei,

while looking into making the Makefile in samples/bpf better handle O= I saw
several warnings when running `make clean && make samples/bpf/`. This series
reduces those warnings.

Thanks.

Alexander Alemayhu (3):
  samples/bpf: add -Wno-unknown-warning-option to clang
  samples/bpf: add static to function with no prototype
  samples/bpf: check before defining offsetof

 samples/bpf/Makefile                    | 1 +
 samples/bpf/cookie_uid_helper_example.c | 2 +-
 samples/bpf/test_lru_dist.c             | 4 +++-
 3 files changed, 5 insertions(+), 2 deletions(-)

-- 
2.9.3
