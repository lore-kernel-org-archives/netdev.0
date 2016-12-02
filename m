From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] samples, bpf: Add automated test for cgroup
 filter attachments
Date: Fri, 2 Dec 2016 10:18:50 -0800
Message-ID: <20161202181848.GB54949@ast-mbp.thefacebook.com>
References: <20161202104230.GA9237@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36288 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751040AbcLBSU3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:20:29 -0500
Received: by mail-pf0-f193.google.com with SMTP id c4so13970895pfb.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:18:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161202104230.GA9237@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 02:42:32AM -0800, Sargun Dhillon wrote:
> This patch adds the sample program test_cgrp2_attach2. This program is
> similar to test_cgrp2_attach, but it performs automated testing of the
> cgroupv2 BPF attached filters. It runs the following checks:
> * Simple filter attachment
> * Application of filters to child cgroups
> * Overriding filters on child cgroups
> 	* Checking that this still works when the parent filter is removed
> 
> The filters that are used here are simply allow all / deny all filters, so
> it isn't checking the actual functionality of the filters, but rather
> the behaviour  around detachment / attachment. If net_cls is enabled,
> this test will fail.
> 
> Signed-off-by: Sargun Dhillon <sargun@sargun.me>

Nice. Thanks for the test!
Acked-by: Alexei Starovoitov <ast@kernel.org>
