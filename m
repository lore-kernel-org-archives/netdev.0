From: "David S. Miller" <davem@davemloft.net>
Subject: Re: local_bh_enable & hard_start_xmit
Date: Mon, 18 Apr 2005 16:01:47 -0700
Message-ID: <20050418160147.6fd7ac9a.davem@davemloft.net>
References: <42642892.2040300@candelatech.com>
	<20050418151421.41a8f64a.davem@davemloft.net>
	<42643BB9.6050705@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <42643BB9.6050705@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Apr 2005 15:59:05 -0700
Ben Greear <greearb@candelatech.com> wrote:

> This would be a good addition to the Documentation/networking/netdevices.txt
> file, or maybe to the dev.c file somewhere (I haven't found an complete list of
> locking notes, though the comments in the dev.c file and the netdevices.txt file
> are a big help.)

So write the patch to add such comments.  It would have taken the
same amount of typing as writing that paragraph saying how great an
addition this would be. :)

> I assume that it is fine to nest calls to local_bh_enable/disable?  (This
> seems to be required since you are supposed to have bh disabled when
> calling hard_start_xmit, but hard_start_xmit can call dev_queue_xmit which
> disables the bh again...)

Yes, this is legal, BH disabling does nest properly.
