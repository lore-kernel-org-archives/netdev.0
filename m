From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
	Topics
Date: Wed, 30 Mar 2005 09:39:43 -0800
Message-ID: <1112204383.11620.2.camel@beastie>
References: <20050327054831.GA15453@waste.org>
	 <1111905181.4753.15.camel@mylaptop>
	 <20050326224621.61f6d917.davem@davemloft.net>
	 <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
	 <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>
	 <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie>
	 <1112130512.1077.107.camel@jzny.localdomain>
	 <20050330152208.GB12672@muc.de>  <20050330172412.GP15453@waste.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, jamal <hadi@cyberus.ca>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Rik van Riel <riel@redhat.com>, andrea@suse.de, michaelc@cs.wisc.edu,
        ksummit-2005-discuss@thunk.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: open-iscsi@googlegroups.com
In-Reply-To: <20050330172412.GP15453@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-30 at 09:24 -0800, Matt Mackall wrote: 
> I seem to recall this being fairly easy to trigger by simply pulling
> the network cable while there's heavy mmap + write load. The system
> will quickly spiral down into OOM and will remain wedged when you plug
> the network back in. With iSCSI, after some extended period all the
> I/Os will have SCSI timeouts and lose everything.

We've discussed that already. SCSI timeout logic just doesn't fit. (see
rfc3720). For iSCSI, SCSI timeout logic *must* be disabled until iSCSI
recovery is complete. host block/unblock logic in recent iSCSI transport
patch will help to implement that.
