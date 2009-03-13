From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v1 1/3] lsm: Relocate the IPv4 security_inet_conn_request() hooks
Date: Fri, 13 Mar 2009 15:39:30 -0400
Message-ID: <200903131539.30903.paul.moore@hp.com>
References: <20090312160934.29454.31004.stgit@flek.lan> <20090312162256.29454.8929.stgit@flek.lan> <20090313.115458.168786837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090313.115458.168786837.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 13 March 2009 02:54:58 pm David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Thu, 12 Mar 2009 12:22:57 -0400
>
> > The current placement of the security_inet_conn_request() hooks do not
> > allow individual LSMs to override the IP options of the connection's
> > request_sock. This is a problem as both SELinux and Smack have the
> > ability to use labeled networking protocols which make use of IP options
> > to carry security attributes and the inability to set the IP options at
> > the start of the TCP handshake is problematic.
> >
> > This patch moves the IPv4 security_inet_conn_request() hooks past the
> > code where the request_sock's IP options are set/reset so that the LSM
> > can safely manipulate the IP options as needed.  This patch intentionally
> > does not change the related IPv6 hooks as IPv6 based labeling protocols
> > which use IPv6 options are not currently implemented, once they are we
> > will have a better idea of the correct placement for the IPv6 hooks.
>
> This looks OK to me:
>
> Acked-by: David S. Miller <davem@davemloft.net>

Great, thanks for taking a look.

-- 
paul moore
linux @ hp

