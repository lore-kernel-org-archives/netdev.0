From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH 05/18] net: use ARRAY_SIZE
Date: Mon, 2 Oct 2017 16:07:36 +0300
Message-ID: <CAHp75VfC2e+h8GCiB-1Rbe=_z3siBBo0WfqEf3qz8yWh8Cm3RQ@mail.gmail.com>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr> <20171001193101.8898-6-jeremy.lefaure@lse.epita.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Chi-Hsien Lin <chi-hsien.lin@cypress.com>,
        Wright Feng <wright.feng@cypress.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <
To: =?UTF-8?B?SsOpcsOpbXkgTGVmYXVyZQ==?= <jeremy.lefaure@lse.epita.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171001193101.8898-6-jeremy.lefaure@lse.epita.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 1, 2017 at 10:30 PM, J=C3=A9r=C3=A9my Lefaure
<jeremy.lefaure@lse.epita.fr> wrote:
> Using the ARRAY_SIZE macro improves the readability of the code. Also,
> it is not always useful to use a variable to store this constant
> calculated at compile time.
>

> +       {&gainctrl_lut_core0_rev0, ARRAY_SIZE(gainctrl_lut_core0_rev0), 2=
6, 192,
> +        32},

For all such cases I would rather put on one line disregard checkpatch
warning for better readability.

--=20
With Best Regards,
Andy Shevchenko
