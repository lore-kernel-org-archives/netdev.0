From: "David S. Miller" <davem@redhat.com>
Subject: Re: e100 "Ferguson" release
Date: Sun, 3 Aug 2003 21:13:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030803211333.12839f66.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com>
	<3F2CA65F.8060105@pobox.com>
	<3F2CBA71.2070503@candelatech.com>
	<20030803003239.4257ef24.davem@redhat.com>
	<3F2DCE56.6030601@pacbell.net>
	<20030803200851.7d46a605.davem@redhat.com>
	<3F2DD6BD.7070504@pacbell.net>
	<20030803204642.684c6075.davem@redhat.com>
	<3F2DDC3A.2040707@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, jgarzik@pobox.com, scott.feldman@intel.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <3F2DDC3A.2040707@pacbell.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 03 Aug 2003 21:08:26 -0700
David Brownell <david-b@pacbell.net> wrote:

> No such callback.  If no resources, they fail -ENOMEM and the
> caller must recover.  Which is why hard_start_xmit() needs to
> do something.

I would suggest something different :-)

For example, what do USB block device drivers do when -ENOMEM comes
back?  Do they just drop the request on the floor?  No, rather they
resubmit the request later without the scsi/block layer knowing
anything about what happened, right?

How do the USB block device drivers know when "later" is?  This is why
I can't believe there is not some kind of "some USB resources have
been freed" event of some sort which USB drivers can use to deal with
this.  :-)
