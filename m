From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 27 May 2005 07:18:52 -0400
Message-ID: <1117192732.6688.8.camel@localhost.localdomain>
References: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, john.ronciak@intel.com, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-26-05 at 14:36 -0700, Mitch Williams wrote:
> The following patch (which applies to 2.6.12rc4) adds a new sysctl
> parameter called 'netdev_packet_weight'.  This parameter controls how many
> backlog work units each RX packet is worth.
> 
> With the parameter set to 0 (the default), NAPI polling works exactly as
> it does today:  each packet is worth one backlog work unit, and the
> maximum number of received packets that will be processed in any given
> softirq is controlled by the 'netdev_max_backlog' parameter.
> 

NAPI uses already using a Weighted Round robin scheduling scheme know as
DRR.
I am not sure providing a weight scale on the weight is enhancing
anything. 
Did you try to just reduce the weight instead to make it smaller
instead? i.e take the resultant weight of you using a shift and set that
as the weight.

cheers,
jamal

 
