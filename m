From: "David S. Miller" <davem@davemloft.net>
Subject: Re: netif_rx packet dumping
Date: Thu, 3 Mar 2005 13:36:59 -0800
Message-ID: <20050303133659.0d224e61.davem@davemloft.net>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	<42278122.6000000@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, rhee@eos.ncsu.edu, jheffner@psc.edu,
        Yee-Ting.Li@nuim.ie, netdev@oss.sgi.com
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <42278122.6000000@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 03 Mar 2005 21:26:58 +0000
Baruch Even <baruch@ev-en.org> wrote:

> I have patches for the SACK processing to improve performance which 
> should reduce the problems with the queues, but they are for 2.6.6 and 
> forward porting them to 2.6.11 is quite a bit of work (too much was 
> changed in conflicting areas). I hope to get to work on this soon.

Please split up your patches properly this time.  Last time you
split up the patches, there was common changes in several of the
patch files.  It looked like you just hand edited the patches in
order to split up the changes, or something like that, and it's
very error prone and made review impossible.

And I'm not accepting your changes if you're going to still add all
that linked list stuff to the generic struct sk_buff.  Adding anything
new to sk_buff is going to make it straddle more L2 cache lines on
ia64 and other 64-bit systems and that totally kills performance.
