From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH] Dynamic airo.c patch for 2.6.10
Date: Wed, 2 Feb 2005 11:22:08 -0800
Message-ID: <20050202192208.GA15344@bougret.hpl.hp.com>
References: <20050202183525.GA13881@bougret.hpl.hp.com> <420126FB.3000007@almaden.ibm.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Javier Achirica <achirica@ttd.net>, netdev@oss.sgi.com
To: Benjamin Reed <breed@almaden.ibm.com>
Content-Disposition: inline
In-Reply-To: <420126FB.3000007@almaden.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Feb 02, 2005 at 11:16:11AM -0800, Benjamin Reed wrote:
> I'm wondering if it would be possible to change IW_ENCODE_TEMP to 
> IW_ENCODE_PERM. I realize that would not be backward compatible, but as 
> you point out, the default assumption is that the keys are volatile.
> 
> ben

	Then you would have to change all other wireless tools (mine,
NetworkManager, KWiFi). By default, those tools will send you a WEP
key without any flag. My assumption is that if a user set a WEP key
explicitely with those tools, you want it to be permanent.
	I think it's easier to fix the only two tools that make use of
dynamic keys.
	Have fun...

	Jean
