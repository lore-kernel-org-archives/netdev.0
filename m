From: Andi Kleen <ak@suse.de>
Subject: Re: 100 network limit
Date: Fri, 29 Aug 2003 02:03:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829020341.706356e7.ak@suse.de>
References: <20030828180019.GH12541@krispykreme>
	<20030828210855.58759b69.ak@suse.de>
	<3F4E783F.6080707@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F4E783F.6080707@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Aug 2003 14:46:39 -0700
Ben Greear <greearb@candelatech.com> wrote:

> 
> Since you can rename devices, that might not work. 

When someone renames eth1 to eth2 and the bitmap  doesn't have eth2 set and selects it 
then you can just retry, searching for further free bits.

When someone renames eth2 to eth1 the rename code should just clear the bit
of eth2 before the rename.

-Andi
