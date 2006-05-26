From: James Morris <jmorris@namei.org>
Subject: Re: [RFC 0/4] NetLabel
Date: Fri, 26 May 2006 14:56:54 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605261455490.4386@d.namei>
References: <44760E29.4070407@hp.com> <Pine.LNX.4.64.0605251938360.27473@d.namei>
 <44771EFB.6030203@hp.com> <Pine.LNX.4.64.0605261156030.3103@d.namei>
 <44772E19.5030907@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, James Morris <jmorris@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <44772E19.5030907@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 May 2006, Paul Moore wrote:

> The NetLabel netlink protocol does have a "version" message which can be
> used to get the version.  My main reason for doing this is not to signal
> changes to existing messages, i.e. break backward compatability, but to
> signal to user space applications that the kernel supports a newer protocol.
> 
> The printk() above is just informative, if that is your main concern I
> can yank it.

Yes, please do.  Linux kernel subsystems don't have versions, use the main 
kernel version if you need to.


- James
-- 
James Morris
<jmorris@namei.org>
