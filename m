From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] fix oops from acenic ethtool
Date: Mon, 14 Jun 2004 13:52:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40CDE5E3.7060009@pobox.com>
References: <20040604145333.34d1600f@dell_ss3.pdx.osdl.net>	<40C9022F.8050102@pobox.com> <20040614094034.7f06445c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@wildopensource.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040614094034.7f06445c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Here is a revised version of the acenic patch:
> 	* use ethtool_ops - solves OOPS on boot up
> 	* put firmware and driver version in correct place in ethtool info response
> 	* get rid of #ifdef SIOCETHTOOL
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


I apologize...  as per my most recent comment to you, I merged your 
earlier patch and fixed the ifdef myself.  Latest should be in -mm tree.

	Jeff
