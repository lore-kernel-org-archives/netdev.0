From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] switch arcnet over to initcalls
Date: Thu, 22 May 2003 08:10:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522081002.A11850@lst.de>
References: <20030521221638.A7575@lst.de> <20030521.162052.08332261.davem@redhat.com> <20030522075711.A11759@lst.de> <20030521.230211.15256464.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030521.230211.15256464.davem@redhat.com>; from davem@redhat.com on Wed, May 21, 2003 at 11:02:11PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 21, 2003 at 11:02:11PM -0700, David S. Miller wrote:
>    From: Christoph Hellwig <hch@lst.de>
>    Date: Thu, 22 May 2003 07:57:11 +0200
>    
>    It's not probed from Space.c so it's probed after most isa devices
>    anyway.
> 
> Yes it is, because com90xx init was being done via arcnet init.
> Which in turn was being done in Space.c

it was done in setup.c
