From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Tue, 30 Sep 2003 09:42:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064911360.21551.49.camel@hades.cambridge.redhat.com>
References: <20030928225941.GW15338@fs.tum.de>
	 <20030928231842.GE1039@conectiva.com.br> <20030928232403.GX15338@fs.tum.de>
	 <20030929220916.19c9c90d.davem@redhat.com>
	 <1064903562.6154.160.camel@imladris.demon.co.uk>
	 <20030930000302.3e1bf8bb.davem@redhat.com>
	 <1064907572.21551.31.camel@hades.cambridge.redhat.com>
	 <20030930010855.095c2c35.davem@redhat.com>
	 <1064910398.21551.41.camel@hades.cambridge.redhat.com>
	 <20030930013025.697c786e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bunk@fs.tum.de, acme@conectiva.com.br, netdev@oss.sgi.com,
        pekkas@netcore.fi, lksctp-developers@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030930013025.697c786e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-09-30 at 01:30 -0700, David S. Miller wrote:
> If 'make modules' doesn't check if the config change has hit a
> dependency that requires the core kernel image to be rebuilt, we need
> to fix that.  'make modules' depends upon the kernel image.

'make modules' should make the modules. If for some reason this really
does require the core kernel image to be present and up to date, perhaps
for modversions, then I agree that it should also rebuild the core
kernel.

If there's no actual dependency on the core kernel image, however, then
it should not be rebuilt for 'make modules'. If 'make modules' was
equivalent to 'make all' then it should not exist at all.

Consider the case where you run a distribution kernel but wish to
compile a couple of extra modules for esoteric hardware, file systems or
protocols. Why would you want 'make modules' to rebuild the kernel
image? The one you're already running is just fine.

Besides, the whole question is mostly is orthogonal to the assertion
that a config change from 'n' to 'm' should not effect changes in the
core kernel.

-- 
dwmw2
