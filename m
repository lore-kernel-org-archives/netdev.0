From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: primary and secondary ip addresses
Date: Fri, 17 Dec 2004 20:25:10 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0412172021190.18385@filer.marasystems.com>
References: <41912F7A.6000408@redhat.com> <200412172003.22319.hasso@estpak.ee>
 <Pine.LNX.4.61.0412171206200.10943@gargoyle.wi.securepipe.com>
 <200412172053.28016.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Martin A. Brown" <mabrown@securepipe.com>, linux-net@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200412172053.28016.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 17 Dec 2004, Hasso Tepper wrote:

> All these tricks don't help if you are using dynamic routing.

Are you seriously saying you are doing dynamic routing for your locally 
attached lans?

source address assignment for routed traffic via gateways is automatically 
derived by the source address assignment for traffic addressed to the 
gateway itself. So even with routing protocols etc you can control the 
source address assignment simply by setting up routing to use the correct 
source address to speak to your gateways, the added routes will then 
inherit the intended source address.

But I am not sure about how you can control this on multicast or broadcast 
traffic in a reasonable manner, mostly because I rarely have to care about 
this on such traffic.

Regards
Henrik
