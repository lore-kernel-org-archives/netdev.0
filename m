From: David Brownell <david-b@pacbell.net>
Subject: Re: e100 "Ferguson" release
Date: Sun, 03 Aug 2003 20:09:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2DCE56.6030601@pacbell.net>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com>	<3F2CA65F.8060105@pobox.com>	<3F2CBA71.2070503@candelatech.com> <20030803003239.4257ef24.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, jgarzik@pobox.com,
   scott.feldman@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030803003239.4257ef24.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>>Although I have not tried this latest patch, the existing e100 and e1000 in
>>2.4.21 seldom seem to return true to this method:  netif_queue_stopped(odev),
>>even when the next hard_start_xmit() call fails.
> 
> 
> Returning an error from hard_start_xmit() from normal ethernet
> drivers is, frankly, a driver bug and should never happen.

What's "normal" mean?

With the current USB stack, network adapters tend to need
memory allocations there.  Those can fail, though it seems
that's not very common.  Doesn't seem like a bug, for all
that I'd rather see the those paths be zero-alloc in 2.7.

- Dave
