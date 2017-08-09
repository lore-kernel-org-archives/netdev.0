From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 3/3] net: rxrpc: Replace time_t type with time64_t type
Date: Wed, 09 Aug 2017 14:26:45 +0100
Message-ID: <11686.1502285205@warthog.procyon.org.uk>
References: <CAK8P3a3L11rXAV8-hE1fNtAZyMBNnQneRm5g7F8VDmk7HjQV4A@mail.gmail.com> <cover.1502246501.git.baolin.wang@linaro.org> <8ac57c96bf5a0695ecc67fd230440b0b9d15740f.1502246502.git.baolin.wang@linaro.org> <CAK8P3a2WU5uYddGrkWhyfNB4qTEDYne_pyCVG6n5b1w+vb1-OQ@mail.gmail.com> <6767.1502271233@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, Baolin Wang <baolin.wang@linaro.org>,
        David Miller <davem@davemloft.net>, james.l.morris@oracle.com,
        "Serge E. Hallyn" <serge@hallyn.com>, marc.dionne@auristor.com,
        Dan Carpenter <dan.carpenter@oracle.com>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Mark Brown <broonie@kernel.org>, keyrings@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a3L11rXAV8-hE1fNtAZyMBNnQneRm5g7F8VDmk7HjQV4A@mail.gmail.com>
Content-ID: <11685.1502285205.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:

> Do you know which format is used in practice? Are both kad and k5 common
> among rxrpc users?

The aklog program I'm using uses the non-XDR interface to push a Kerberos 5
ticket to the kernel, so it doesn't actually invoke rxrpc_preparse_xdr() from
rxrpc_preparse().

David
