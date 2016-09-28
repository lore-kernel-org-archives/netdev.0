From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 06:49:51 -0700
Message-ID: <1475070591.28155.103.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160928090357.GT1876@uranus.lan>
         <caef7649-9d25-6429-eeab-96c027d6cbc2@mojatatu.com>
         <20160928101726.GU1876@uranus.lan>
         <8293413c-a81d-f7ff-24f0-8f58ce877116@mojatatu.com>
         <20160928105147.GV1876@uranus.lan>
         <484dedaf-4e81-9a5a-ffb8-2c65b373c3a0@mojatatu.com>
         <20160928112703.GW1876@uranus.lan>
         <1475067432.28155.90.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160928130357.GC1876@uranus.lan>
         <1475069348.28155.98.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160928134309.GE1876@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160928134309.GE1876@uranus.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-09-28 at 16:43 +0300, Cyrill Gorcunov wrote:
> On Wed, Sep 28, 2016 at 06:29:08AM -0700, Eric Dumazet wrote:
> > > 
> > > Oh, crap :( I've been looking into uapi headers, found that we
> > > use anonymous unions (for example include/uapi/linux/bcache.h)
> > > and thought it will be safe (and my test builds didn't fail).
> > > Are you happen to know which gcc versions cant do that?
> > 
> > The most recent example I have in mind is a kbuild bot report on the
> > recent TCP BBR patches. We had to rework the patch to avoid the problem.
> > 
> > If I remember well, this was a gcc-4.7, but not on x86.
> 
> 4.7 is pretty widespread, so I've to think...

Sorry, 4.4.7 it was

https://www.mail-archive.com/netdev@vger.kernel.org/msg128714.html
