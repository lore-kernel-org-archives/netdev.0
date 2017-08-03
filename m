From: Sumit Semwal <sumit.semwal@linaro.org>
Subject: latest kselftest with stable tree: bpf failures
Date: Thu, 3 Aug 2017 20:39:36 +0530
Message-ID: <CAO_48GFVH_ciiJRuse55hp2sARYDd0hGncfRembnBCYd_re0JQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, "# 3.4.x" <stable@vger.kernel.org>,
        "open list:KERNEL SELFTEST FRAMEWORK"
        <linux-kselftest@vger.kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Shuah Khan <shuah@kernel.org>
To: ast@kernel.org, daniel@iogearbox.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Alexei, Daniel, and the bpf community,

As part of trying to improve stable kernels' testing, we're running
~current kselftests with stable kernels (4.4 and 4.9 for now), and
reporting issues.

While doing this, we see some failures in the bpf tests - most of them
look like they are due to trying to test missing features.

In Greg's opinion (and mine too :) ), when tests can't find the
feature they're trying to test, they should 'degrade gracefully', eg
perhaps SKIP instead of FAIL( or core dumps).

As you guys are the experts in BPF, may I request someone from this
community to look at how can it be achieved with bpf tests?

Appreciate the help!

Best regards,
Sumit.

--=20
Thanks and regards,

Sumit Semwal
Linaro Mobile Group - Kernel Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
