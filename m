From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/2] samples, bpf: Refactor
 test_current_task_under_cgroup - separate out helpers
Date: Fri, 2 Dec 2016 10:17:49 -0800
Message-ID: <20161202181747.GA54949@ast-mbp.thefacebook.com>
References: <20161202104217.GA9231@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35055 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753799AbcLBSRy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:17:54 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so8561396pga.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:17:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161202104217.GA9231@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 02:42:18AM -0800, Sargun Dhillon wrote:
> This patch modifies test_current_task_under_cgroup_user. The test has
> several helpers around creating a temporary environment for cgroup
> testing, and moving the current task around cgroups. This set of
> helpers can then be used in other tests.
> 
> Signed-off-by: Sargun Dhillon <sargun@sargun.me>

lgtm
Acked-by: Alexei Starovoitov <ast@kernel.org>
