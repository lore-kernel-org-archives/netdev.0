From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH v3 REPOST] xen-netfront: delay gARP until backend
 switches to Connected
Date: Fri, 9 Dec 2011 21:23:00 +0000
Message-ID: <1323465781.20936.49.camel@dagon.hellion.org.uk>
References: <1323430738-3798-1-git-send-email-lersek@redhat.com>
	 <20111209.134514.2071890208094978847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "lersek@redhat.com" <lersek@redhat.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"jeremy@goop.org" <jeremy@goop.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111209.134514.2071890208094978847.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-12-09 at 18:45 +0000, David Miller wrote:
> From: Laszlo Ersek <lersek@redhat.com>
> Date: Fri,  9 Dec 2011 12:38:58 +0100
> 
> > These two together provide complete ordering. Sub-condition (1) is
> > satisfied by pvops commit 43223efd9bfd.
> 
> I don't see this commit in Linus's tree,

The referenced commit is in
git://git.kernel.org/pub/scm/linux/kernel/git/jeremy/xen.git#xen/next-2.6.32  some people call the "pvops tree" but there's no reason to expect someone outside the Xen world to know that...

A better reference would have been 6b0b80ca7165 in
git://xenbits.xen.org/people/ianc/linux-2.6.git#upstream/dom0/backend/netback-history which is the precise branch that was flattened to make f942dc2552b8, which is the upstream commit that added netback, so this change is already in upstream.

Ian.
