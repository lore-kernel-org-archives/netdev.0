From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/unix: support SCM_SECURITY for stream
 sockets
Date: Wed, 10 Jun 2015 22:49:34 -0700 (PDT)
Message-ID: <20150610.224934.759313464983844581.davem@davemloft.net>
References: <1433940299-6207-1-git-send-email-sds@tycho.nsa.gov>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	paul@paul-moore.com
To: sds@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1433940299-6207-1-git-send-email-sds@tycho.nsa.gov>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Smalley <sds@tycho.nsa.gov>
Date: Wed, 10 Jun 2015 08:44:59 -0400

> SCM_SECURITY was originally only implemented for datagram sockets,
> not for stream sockets.  However, SCM_CREDENTIALS is supported on
> Unix stream sockets.  For consistency, implement Unix stream support
> for SCM_SECURITY as well.  Also clean up the existing code and get
> rid of the superfluous UNIXSID macro.
> 
> Motivated by https://bugzilla.redhat.com/show_bug.cgi?id=1224211,
> where systemd was using SCM_CREDENTIALS and assumed wrongly that
> SCM_SECURITY was also supported on Unix stream sockets.
> 
> Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
> Acked-by: Paul Moore <paul@paul-moore.com>

Applied, thank you.
