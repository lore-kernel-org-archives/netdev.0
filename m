From: Kees Cook <keescook@chromium.org>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Wed, 8 Mar 2017 14:36:04 -0800
Message-ID: <CAGXu5jLB_+47FEJYTYJ5u6-u+vOBpWo_0tWuiNKnGmuMjL-mMQ@mail.gmail.com>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com>
 <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com> <58B88353.2010508@iogearbox.net>
 <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com> <58C08535.3070000@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, "the arch/x86 maintainers" <x86@kernel.org>,
        Laura Abbott <labbott@redhat.com>,
        "David S. Miller" <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:35502 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751286AbdCHWgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 17:36:46 -0500
Received: by mail-it0-f53.google.com with SMTP id m27so58647057iti.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 14:36:05 -0800 (PST)
In-Reply-To: <58C08535.3070000@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 8, 2017 at 2:27 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> [   28.474232] rodata_test: test data was not read only
> [...]

In my tests so far, I've never been able to get rodata_test to fail
(Qemu 2.5.0, Ubuntu). I'll retry with your .config and see if I can
recheck under Qemu 2.7.1. Do you see these failures on real hardware?

-Kees

-- 
Kees Cook
Pixel Security
