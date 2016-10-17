From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] bpf: add initial suite for selftests
Date: Mon, 17 Oct 2016 13:45:39 -0700
Message-ID: <20161017204537.GB77495@ast-mbp.thefacebook.com>
References: <cover.1476705709.git.daniel@iogearbox.net>
 <08cc05da80eda6abe3287c6d4876c31bb6107109.1476705709.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33770 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932221AbcJQUp3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 16:45:29 -0400
Received: by mail-pf0-f195.google.com with SMTP id i85so10000226pfa.0
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 13:45:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <08cc05da80eda6abe3287c6d4876c31bb6107109.1476705709.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 02:28:36PM +0200, Daniel Borkmann wrote:
> Add a start of a test suite for kernel selftests. This moves test_verifier
> and test_maps over to tools/testing/selftests/bpf/ along with various
> code improvements and also adds a script for invoking test_bpf module.
> The test suite can simply be run via selftest framework, f.e.:
> 
>   # cd tools/testing/selftests/bpf/
>   # make
>   # make run_tests
> 
> Both test_verifier and test_maps were kind of misplaced in samples/bpf/
> directory and we were looking into adding them to selftests for a while
> now, so it can be picked up by kbuild bot et al and hopefully also get
> more exposure and thus new test case additions.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
