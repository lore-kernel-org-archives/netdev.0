From: David Brownell <david-b@pacbell.net>
Subject: Re: e100 "Ferguson" release
Date: Mon, 04 Aug 2003 10:38:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2E9A09.7000707@pacbell.net>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com>	<3F2CA65F.8060105@pobox.com>	<3F2CBA71.2070503@candelatech.com>	<20030803003239.4257ef24.davem@redhat.com>	<3F2DCE56.6030601@pacbell.net>	<20030803200851.7d46a605.davem@redhat.com>	<3F2DD6BD.7070504@pacbell.net>	<20030803204642.684c6075.davem@redhat.com>	<3F2DDC3A.2040707@pacbell.net> <20030803211333.12839f66.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, jgarzik@pobox.com, scott.feldman@intel.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030803211333.12839f66.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>
> For example, what do USB block device drivers do when -ENOMEM comes
> back?  Do they just drop the request on the floor?  No, rather they
> resubmit the request later without the scsi/block layer knowing
> anything about what happened, right?

I didn't notice any code to retry, but I did see some that morphed
ENOMEM into a generic scsi "error".  Scsi presumably does something
more or less intelligent then.

The network layer on the other hand _does_ have hooks for retrying,
not that they're used much.

- Dave
