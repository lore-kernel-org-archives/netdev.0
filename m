From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 14:34:51 -0800
Message-ID: <20041118143451.3dae3ffb.davem@davemloft.net>
References: <Xine.LNX.4.44.0411181158110.5096-100000@thoron.boston.redhat.com>
	<Xine.LNX.4.44.0411181219590.5236-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chrisw@osdl.org, ross.axe@blueyonder.co.uk, netdev@oss.sgi.com,
        sds@epoch.ncsc.mil, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0411181219590.5236-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Nov 2004 12:25:21 -0500 (EST)
James Morris <jmorris@redhat.com> wrote:

> Updated patch below (with Chris Wright's wrapper idea).
> 
> This now fixes both issues.
> 
> 1) Don't call security_unix_may_send() hook during sendmsg() for 
> SOCK_SEQPACKET, and ensure that sendmsg() can only be called on a 
> connected socket so as not to bypass the security_unix_stream_connect() 
> hook.
> 
> 2) Return -EINVAL if sendto() is called on SOCK_SEQPACKET with an address 
> supplied.
> 
> Please review and apply if ok.
> 
> 
> Signed-off-by: James Morris <jmorris@redhat.com>

Looks good, applied thanks James.
