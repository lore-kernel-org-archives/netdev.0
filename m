From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 4/5] [bonding] backport 2.6 changes to 2.4
Date: Thu, 07 Aug 2003 20:28:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F32EEA3.2000507@pobox.com>
References: <200307302007.21369.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Amir Noam <amir.noam@intel.com>
In-Reply-To: <200307302007.21369.amir.noam@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Amir Noam wrote:
> Backported from 2.6:
> Don't dynamically allocate a net_device_stats structure for each bond,
> instead allocate it with the bonding structure.
> 
> Since they are always allocated together anyway, we might as well put
> the stats struct within the bond.


applied to 2.4.
