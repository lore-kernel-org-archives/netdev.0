From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Problem with recent CMSG_COMPAT_OK fix
Date: Mon, 10 Jan 2005 12:52:06 -0800
Message-ID: <20050110125206.05ee6cfe.davem@davemloft.net>
References: <20050104165934.GJ7761@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050104165934.GJ7761@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 4 Jan 2005 17:59:34 +0100
Olaf Kirch <okir@suse.de> wrote:

> The recent fixes for cmsg_len handling seem to break 32bit compatibility
> at least on x86_64. The new CMSG_COMPAT_OK macro requires that cmsg_len
> is greater or equal the size of struct cmsghdr, which is the 64bit
> version of the struct.  The code should really check against the size
> of struct compat_cmsghdr.
> 
> Signed-off-by: Olaf Kirch <okir@suse.de>

Applied, thanks Olaf.
