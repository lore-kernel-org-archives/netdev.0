From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 0/6] In-kernel QMI handling
Date: Tue, 08 Aug 2017 13:02:37 +0200
Message-ID: <8737921fw2.fsf@miraculix.mork.no>
References: <20170804145938.25427-1-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Andy Gross <andy.gross@linaro.org>,
        David Brown <david.brown@linaro.org>,
        linux-arm-msm@vger.kernel.org, linux-soc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170804145938.25427-1-bjorn.andersson@linaro.org> (Bjorn
        Andersson's message of "Fri, 4 Aug 2017 07:59:32 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson <bjorn.andersson@linaro.org> writes:

> This series starts by moving the common definitions of the QMUX protocol =
to the
> uapi header, as they are shared with clients - both in kernel and userspa=
ce.
>
> This series then introduces in-kernel helper functions for aiding the han=
dling
> of QMI encoded messages in the kernel. QMI encoding is a wire-format used=
 in
> exchanging messages between the majority of QRTR clients and services.

Interesting!  I tried to add some QMI handling in the kernel a few years
ago, but was thankfully voted down.  See
https://www.spinics.net/lists/netdev/msg183101.html and the following
discussion. I am convinced that was the right decision, for the client
side at least. The protocol is just too extensive and ever-growing to be
implemented in the kernel. We would be catching up forever.

Note that I had very limited knowledge of the protocol at the time I
wrote that driver.  Still have, in fact :-)


Bj=C3=B8rn
