From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH] xfrm: fix regression introduced by xdst pcpu cache
Date: Tue, 31 Oct 2017 15:15:20 +0100
Message-ID: <20171031141520.GC7663@breakpoint.cc>
References: <20171030145843.13496-1-sds@tycho.nsa.gov>
 <20171031111122.GB7663@breakpoint.cc>
 <1509457420.20694.4.camel@tycho.nsa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
        selinux@tycho.nsa.gov, davem@davemloft.net,
        Paul Moore <paul@paul-moore.com>
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1509457420.20694.4.camel@tycho.nsa.gov>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Smalley <sds@tycho.nsa.gov> wrote:
> It is a regression; the correct SA was being used prior to the xdst
> pcpu cache commit.

I don't doubt that at all.  I would like to understand why the flow
cache did not have this problem.

> easily run on a Fedora VM,
> git clone https://github.com/SELinuxProject/selinux-testsuite/
> sudo dnf install perl-Test perl-Test-Harness perl-Test-Simple selinux-policy-devel gcc libselinux-devel net-tools netlabel_tools iptables
> sudo make -C policy load
> cd tests/inet_socket
> while sudo ./test; do : ; done

Thanks, I'll have a look.
