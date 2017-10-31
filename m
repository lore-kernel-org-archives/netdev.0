From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [RFC PATCH 0/5] Add SELinux SCTP protocol support
Date: Tue, 31 Oct 2017 15:26:44 -0200
Message-ID: <20171031172644.GF3675@localhost.localdomain>
References: <20171017135359.4010-1-richard_c_haines@btinternet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-security-module@vger.kernel.org,
        paul@paul-moore.com, vyasevich@gmail.com, nhorman@tuxdriver.com,
        sds@tycho.nsa.gov, eparis@parisplace.org
To: Richard Haines <richard_c_haines@btinternet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49478 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753888AbdJaR0r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 13:26:47 -0400
Content-Disposition: inline
In-Reply-To: <20171017135359.4010-1-richard_c_haines@btinternet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 02:53:59PM +0100, Richard Haines wrote:
> This patch set adds SELinux support to SCTP and incorporates all the
> comments received from my previous attemps (thanks to all who responded).
> There are also other changes mainly supporting ip options so that CIPSO
> and CALIPSO work over SCTP.
> 
> The kernel patches have been built on Fedora 26 with kernel 4.13.4 plus the
> following userspace patches to enable testing:
> 
> 1) Updates to libsepol 2.7 to support the sctp portcon statement.
>    The patch is available from:
>          http://arctic.selinuxproject.org/~rhaines/selinux-sctp/
>          selinux-Add-support-for-the-SCTP-portcon-keyword.patch
> 
> 2) Updates to the SELinux Test Suite adding SCTP tests. Please read the
>    selinux-testsuite/README.sctp for details. The patch is available from:
>          http://arctic.selinuxproject.org/~rhaines/selinux-sctp/
>          selinux-testsuite-Add-SCTP-test-support.patch
> 
> 3) Updates to lksctp-tools that show SELinux info in sctp_darn and
>    sctp_test. It also contains a minor patch for test_1_to_1_connect.c
>    as when CIPSO/CALIPSO configured, NetLabel returns a different error
>    code for illegal addresses in test 5. The patch is available from:
>          http://arctic.selinuxproject.org/~rhaines/selinux-sctp/
>          lksctp-tools-Add-SELinux-support-to-sctp_test-and-sc.patch
> 
> All SCTP lksctp-tools/src/func_tests run correctly in enforcing mode.
> 
> All SCTP regression tests "./sctp-tests run" run correctly in enforcing
> mode. These tests are obtained from: https://github.com/sctp/sctp-tests
> 
> The selinux-testsuite patch also adds remote tests (that need some manual
> configuration). These are useful for testing CIPSO/CALIPSO over a network
> with a number of categories to produce large ip option fields with various
> message sizes forcing fragmentation etc..
> 
> 
> Richard Haines (5):
>   security: Add support for SCTP security hooks
>   sctp: Add ip option support
>   sctp: Add LSM hooks
>   netlabel: Add SCTP support
>   selinux: Add SCTP support

Other than the notes I just sent, patchset LGTM.

Thanks,
Marcelo
