From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Fix SELinux for removal of i_sock
Date: Fri, 1 Apr 2005 12:35:20 -0800
Message-ID: <20050401123520.7532528b.davem@davemloft.net>
References: <1112385997.14481.192.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        matthew@wil.cx
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Smalley <sds@tycho.nsa.gov>
In-Reply-To: <1112385997.14481.192.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 01 Apr 2005 15:06:37 -0500
Stephen Smalley <sds@tycho.nsa.gov> wrote:

> This patch against -bk eliminates the use of i_sock by SELinux as it
> appears to have been removed recently, breaking the build of SELinux in
> -bk.  Simply replacing the i_sock test with an S_ISSOCK test would be
> unsafe in the SELinux code, as the latter will also return true for the
> inodes of socket files in the filesystem, not just the actual socket
> objects IIUC.  Hence this patch reworks the SELinux code to avoid the
> need to apply such a test in the first place, part of which was
> obsoleted anyway by earlier changes to SELinux.  Please apply.
> 
> Signed-off-by:  Stephen Smalley <sds@tycho.nsa.gov>
> Signed-off-by:  James Morris <jmorris@redhat.com>

Applied, thanks Stephen.
