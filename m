From: "David S. Miller" <davem@redhat.com>
Subject: Re: Network buffer hang was Re: [PATCH] 2.6 workaround for
 Athlon/Opteron prefetch errata
Date: Thu, 11 Sep 2003 18:41:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911184103.2646b189.davem@redhat.com>
References: <uqD5.3BI.3@gated-at.bofh.it>
	<m3iso0arlx.fsf@averell.firstfloor.org>
	<0a5801c37821$54eb8180$890010ac@edumazet>
	<20030911051121.GA7751@colin2.muc.de>
	<0a7701c37829$c4bdef40$890010ac@edumazet>
	<20030911120956.GB7751@colin2.muc.de>
	<0b2901c37867$1db399a0$890010ac@edumazet>
	<3F612570.1010303@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, jun.nakajima@intel.com, ak@muc.de,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F612570.1010303@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Sep 2003 18:46:24 -0700
Ben Greear <greearb@candelatech.com> wrote:

> I was using kernel 2.4.21 or so, and had tcp buffers turned up
> quite high.

You seal your own fate by setting this too high.  It's meant
to keep TCP from commiting too much system memory to itself.
