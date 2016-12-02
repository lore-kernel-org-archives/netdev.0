From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next 0/2] samples, bpf: Refactor; Add automated tests for
 cgroups
Date: Fri, 2 Dec 2016 02:42:03 -0800
Message-ID: <20161202104201.GA9217@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@zonque.org, ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35328 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933923AbcLBKmG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 05:42:06 -0500
Received: by mail-io0-f180.google.com with SMTP id a124so474169475ioe.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 02:42:06 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches are around refactoring out some old, reusable code from the 
existing test_current_task_under_cgroup_user test, and adding a new, automated 
test.

There is some generic cgroupsv2 setup & cleanup code, given that most 
environment still don't have it setup by default. With this code, we're able
to pretty easily add an automated test for future cgroupsv2 functionality.

Sargun Dhillon (2):
  samples, bpf: Refactor test_current_task_under_cgroup - separate out
    helpers
  samples, bpf: Add automated test for cgroup filter attachments

 samples/bpf/Makefile                              |   4 +-
 samples/bpf/cgroup_helpers.c                      | 177 ++++++++++++++++++++++
 samples/bpf/cgroup_helpers.h                      |  16 ++
 samples/bpf/test_cgrp2_attach2.c                  | 132 ++++++++++++++++
 samples/bpf/test_current_task_under_cgroup_user.c | 108 +++----------
 5 files changed, 352 insertions(+), 85 deletions(-)
 create mode 100644 samples/bpf/cgroup_helpers.c
 create mode 100644 samples/bpf/cgroup_helpers.h
 create mode 100644 samples/bpf/test_cgrp2_attach2.c

-- 
2.7.4
