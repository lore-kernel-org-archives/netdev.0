From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] e1000 module parameter incompatiablity
Date: Tue, 8 Jun 2004 12:39:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608123933.70816c41@dell_ss3.pdx.osdl.net>
References: <468F3FDA28AA87429AD807992E22D07E0158A1CD@orsmsx408>
	<20040608110420.3b93338d@dell_ss3.pdx.osdl.net>
	<40C607D9.5090506@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        cramerj
 <cramerj@intel.com>, "Ronciak, John" <john.ronciak@intel.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40C607D9.5090506@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 08 Jun 2004 14:39:21 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > E1000 driver is mixing new style 'module_param' with old style 'MODULE_PARM'
> > this generates the runtime warning
> > 	e1000: Ignoring new-style parameters in presence of obsolete ones
> > and prevents using module parameters to set ring size.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> why not fix the others?

Cause their buried in ugly macros in another place.
