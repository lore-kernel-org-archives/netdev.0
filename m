From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch 2.4] kernel oops on VLAN removal
Date: Wed, 20 Aug 2003 11:31:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820113132.30d067a6.davem@redhat.com>
References: <3F424405.6020002@mrv.com>
	<20030819124154.75ec0383.davem@redhat.com>
	<3F436EE7.1030104@mrv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eran Mann <emann@mrv.com>
In-Reply-To: <3F436EE7.1030104@mrv.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Aug 2003 15:51:51 +0300
Eran Mann <emann@mrv.com> wrote:

> David S. Miller wrote:
> > Can someone check out 2.6.x?
> > 
> It looks the same in 2.6.0-test3. The patch applies (with small offsets) 
> and works (the oops is much harder to trigger in 2.6.x since 
> PROC_NDYNAMIC is increased to 16384, I had to reduce it to 4096 to 
> trigger the oops).

Thanks, I've put the patch into my 2.6.x tree.
