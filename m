From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: 2.6.19-rc6 : Spontaneous reboots, stack overflows - seems to implicate xfs, scsi, networking, SMP
Date: Wed, 22 Nov 2006 23:47:31 -0700
Message-ID: <20061123064731.GB18567@parisc-linux.org>
References: <9a8748490611211551v2ebe88fel2bcf25af004c338a@mail.gmail.com> <9a8748490611220458w4d94d953v21f7a29a9f1bdb72@mail.gmail.com> <20061123011809.GY37654165@melbourne.sgi.com> <20061122.201013.112290046.davem@davemloft.net> <20061123043543.GI3078@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dgc@sgi.com,
	jesper.juhl@gmail.com, chatz@melbourne.sgi.com,
	linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
	xfs-masters@oss.sgi.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: Al Viro <viro@ftp.linux.org.uk>
Content-Disposition: inline
In-Reply-To: <20061123043543.GI3078@ftp.linux.org.uk>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 04:35:43AM +0000, Al Viro wrote:
> On Wed, Nov 22, 2006 at 08:10:13PM -0800, David Miller wrote:
> > I would even say 10 function calls deep to allocate file blocks
> > is overkill, but 22 it just astronomically bad.
> 
> Especially since a large part is due to cxfs...

... and patches sent in the past to remove layers from XFS have been
NAKed due to CXFS

http://oss.sgi.com/archives/xfs/2003-08/msg00166.html
http://oss.sgi.com/archives/xfs/2003-08/msg00167.html
http://oss.sgi.com/archives/xfs/2003-08/msg00168.html
http://oss.sgi.com/archives/xfs/2003-08/msg00171.html

Maybe IRIX is now sufficiently dead that the last argument doesn't
matter any more.
