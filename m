From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: bpf.h drift due to bpf_sk_redirect_map()
Date: Thu, 26 Oct 2017 10:56:28 -0300
Message-ID: <20171026135628.GJ7045@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Adrian Hunter <adrian.hunter@intel.com>,
        David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@kernel.org>,
        Namhyung Kim <namhyung@kernel.org>,
        Wang Nan <wangnan0@huawei.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

	Recently the tools/perf/ build system noticed drift in
tools/include/uapi/linux/bpf.h from its master copy
include/uapi/linux/bpf.h, which comes from changes from you, can you
please check this?

[acme@jouet linux]$ diff -u tools/include/uapi/linux/bpf.h include/uapi/linux/bpf.h
--- tools/include/uapi/linux/bpf.h	2017-10-26 08:10:15.980323396 -0300
+++ include/uapi/linux/bpf.h	2017-10-19 14:26:13.859622885 -0300
@@ -569,10 +569,9 @@
  *     @flags: reserved for future use
  *     Return: 0 on success or negative error code
  *
- * int bpf_sk_redirect_map(skb, map, key, flags)
+ * int bpf_sk_redirect_map(map, key, flags)
  *     Redirect skb to a sock in map using key as a lookup key for the
  *     sock in map.
- *     @skb: pointer to skb
  *     @map: pointer to sockmap
  *     @key: key to lookup sock in map
  *     @flags: reserved for future use
[acme@jouet linux]$

- Arnaldo
