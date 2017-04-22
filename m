From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: compile issue in latest iproute2
Date: Sat, 22 Apr 2017 08:31:49 -0400
Message-ID: <cecf76aa-2883-741e-1901-2f4850e2c188@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33816 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423267AbdDVMbv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 08:31:51 -0400
Received: by mail-io0-f196.google.com with SMTP id h41so37232264ioi.1
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 05:31:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I dont think is a kernel uapi - but it was failing compiling
when HAVE_ELF is false.
-----
jhs@jhs-UX:~/git-trees/others/iproute-with-ck$ git diff include/bpf_util.h
diff --git a/include/bpf_util.h b/include/bpf_util.h
index 5361dab..edca339 100644
--- a/include/bpf_util.h
+++ b/include/bpf_util.h
@@ -266,7 +266,7 @@ int bpf_send_map_fds(const char *path, const char *obj);
  int bpf_recv_map_fds(const char *path, int *fds, struct bpf_map_aux *aux,
                      unsigned int entries);
  #else
-static inline int bpf_send_map_fds(const char *path, const char *obj)
+inline int bpf_send_map_fds(const char *path, const char *obj)
  {
         return 0;
  }
-----

Let me know if you want a formal patch or feel free to take it.

cheers,
jamal
