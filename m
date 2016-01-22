From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 1/3] xen-netback: fix license ident used in
 MODULE_LICENSE
Date: Fri, 22 Jan 2016 13:14:24 +0000
Message-ID: <56A22B30.3020206@citrix.com>
References: <1453466057-7176-1-git-send-email-wei.liu2@citrix.com>
 <1453466057-7176-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Ian Campbell <ian.campbell@citrix.com>,
	"open list:XEN NETWORK BACKEND DRIVER" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>,
	Xen-devel <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453466057-7176-2-git-send-email-wei.liu2@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/01/16 12:34, Wei Liu wrote:
> The comment at the beginning of the file is the canonical source of
> licenses for this module. Currently it contains GPL and MIT license. Fix
> the code to reflect the reality.

"The MIT license" isn't really a thing.  The closest is the X11
license[1], but this not applicable here either since the text in the
drivers does not refer to X11 trademarks etc.

You can either use "GPL" which would be correct for a Linux kernel
module since the alternate only applies when distributed separately from
Linux ("or, when distributed separately from the Linux kernel or
incorporated into other software packages, subject to the following
license:"); or you can use "GPL and additional rights".

(Or you could just leave it as-is since "Dual BSD/GPL" is close enough.)

David

[1] http://www.gnu.org/licenses/license-list.html#X11License
