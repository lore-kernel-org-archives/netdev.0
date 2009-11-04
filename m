From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: Re: [PATCH 3/3] net: check kern before calling security subsystem
Date: Wed, 4 Nov 2009 15:32:20 -0200
Message-ID: <20091104173220.GH2603@ghostprotocols.net>
References: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com> <20091104163224.27133.88570.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nhorman@redhat.com, dwalsh@redhat.com,
	davem@davemloft.net, linux-security-module@vger.kernel.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091104163224.27133.88570.stgit@paris.rdu.redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Nov 04, 2009 at 11:32:24AM -0500, Eric Paris escreveu:
> Before calling capable(CAP_NET_RAW) check if this operations is on behalf
> of the kernel or on behalf of userspace.  Do not do the security check if
> it is on behalf of the kernel.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
