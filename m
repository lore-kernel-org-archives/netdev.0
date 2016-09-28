From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 08:09:24 -0400 (EDT)
Message-ID: <20160928.080924.262829446101549341.davem@davemloft.net>
References: <484dedaf-4e81-9a5a-ffb8-2c65b373c3a0@mojatatu.com>
        <20160928112703.GW1876@uranus.lan>
        <696ed966-991c-30f7-9a1c-d91a94c9304c@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, eric.dumazet@gmail.com,
        dsa@cumulusnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: jhs@mojatatu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <696ed966-991c-30f7-9a1c-d91a94c9304c@mojatatu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Wed, 28 Sep 2016 08:06:51 -0400

> I understood well your point;-> Maybe my response was not clear:
> _nobody should be fscking fondling pad fields_ setting them or
> otherwise.

Especially considering potential future uses of the field, existing
users absolutely must zero out the field.

Whether this is via a memset() of the entire structure or via
an explicit initialization to zero is their choice.

So setting 'pad' is in fact valid.
