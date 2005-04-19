From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [ANNOUNCE] Linux-iSCSI High-Performance Initiator
Date: Tue, 19 Apr 2005 15:39:20 +0100
Message-ID: <20050419143920.GA13939@infradead.org>
References: <4265170E.5040102@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alex Aizman <itn780@yahoo.com>
Content-Disposition: inline
In-Reply-To: <4265170E.5040102@yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 19, 2005 at 07:34:54AM -0700, Alex Aizman wrote:
> The entire iSCSI Initiator's data path over TCP consists of 2 files:
> 
> http://www.open-iscsi.org/src/iscsi_tcp.c
> 
> http://www.open-iscsi.org/src/iscsi_tcp.h
> 
> (The first file is 73K, I sent yesterday - seems it didn't make it).
> 
> It'd be great to get this code reviewed from the networking perspective.

Note:  I've done quite a bit review from the scsi perspective, but I asked
the iscsi people to send it for review over here aswell.  It's doing quite
a lot of deep magic in network land, and maybe some of that should move
into more generic APIs in the networking layer.
