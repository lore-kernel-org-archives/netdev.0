From: Stephen Smalley <sds@epoch.ncsc.mil>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
	using SELinux and SOCK_SEQPACKET
Date: Mon, 15 Nov 2004 08:31:17 -0500
Message-ID: <1100525477.31773.38.camel@moss-spartans.epoch.ncsc.mil>
References: <4197A037.1020307@blueyonder.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261596AbUKONgK@vger.kernel.org>
To: Ross Kendall Axe <ross.axe@blueyonder.co.uk>
In-Reply-To: <4197A037.1020307@blueyonder.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2004-11-14 at 13:13, Ross Kendall Axe wrote:
> With CONFIG_SECURITY_NETWORK=y and CONFIG_SECURITY_SELINUX=y, using
> SOCK_SEQPACKET unix domain sockets causes an oops in the superfluous(?)
> call to security_unix_may_send in sock_dgram_sendmsg. This patch avoids
> making this call for SOCK_SEQPACKET sockets.

I'd prefer to track down the actual issue in the SELinux code and
correct it than just omit the security hook call entirely.  Do you have
the Oops output and a trivial test case?  Thanks.

-- 
Stephen Smalley <sds@epoch.ncsc.mil>
National Security Agency
