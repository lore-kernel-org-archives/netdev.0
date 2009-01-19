From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 2/5] virtio_net: Add a virtqueue for outbound control
 commands
Date: Mon, 19 Jan 2009 09:32:44 +0000
Message-ID: <1232357564.5627.17.camel@blaa>
References: <20090116211312.22836.34331.stgit@debian.lart>
	 <20090116211323.22836.40477.stgit@debian.lart>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090116211323.22836.40477.stgit@debian.lart>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-01-16 at 14:13 -0700, Alex Williamson wrote:
> This will be used for RX mode, MAC filter table, VLAN filtering, etc...
> 
> The control transaction consists of one or more "out" sg entries and
> one or more "in" sg entries.  The first out entry contains a header
> defining the class and command.  Additional out entries may provide
> data for the command.  The last in entry provides a status response
> back from the command.
> 
> Virtqueues typically run asynchronous, running a callback function
> when there's data in the channel.  We can't readily make use of this
> in the command paths where we need to use this.  Instead, we kick
> the virtqueue and spin.  The kick causes an I/O write, triggering an
> immediate trap into the hypervisor.
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>

Acked-by: Mark McLoughlin <markmc@redhat.com>

Cheers,
Mark.

