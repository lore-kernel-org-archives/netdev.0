From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] net: use IS_ENABLED() instead of checking for
 built-in or module
Date: Sat, 10 Sep 2016 21:19:28 -0700 (PDT)
Message-ID: <20160910.211928.1782362547702903708.davem@davemloft.net>
References: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        nikolay@cumulusnetworks.com, jchapman@katalix.com,
        aduyck@mirantis.com, vyasevich@gmail.com, fw@strlen.de,
        acme@ghostprotocols.net, yoshfuji@linux-ipv6.org,
        daniel@iogearbox.net, stephen@networkplumber.org,
        tom@herbertland.com, linux-sctp@vger.kernel.org, a@unstable.cc,
        jhs@mojatatu.com, herbert@gondor.apana.org.au, mugunthanvnm@ti.com,
        steffen.klassert@secunet.com, edumazet@google.com,
        felipe.balbi@linux.intel.com, netdev@vger.kernel.org,
        jiri@mellanox.com, nhorman@tuxdriver.com, jarod@redhat.com,
        kaber@trash.net, pabeni@redhat.com, jmorris@namei.org
To: javier@osg.samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier@osg.samsung.com>
Date: Fri,  9 Sep 2016 08:43:12 -0400

> This trivial series replace the open coding to check for a Kconfig symbol
> being built-in or module, with IS_ENABLED() macro that does exactly that.
> 
> Using the macro makes the code more readable by helping abstract away some
> of the Kconfig built-in and module enable details.

Series applied, thanks.
