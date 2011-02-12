From: Andrew Beverley <andy@andybev.com>
Subject: Re: any way to reset all marked connections when using CONNMARK?
Date: Sat, 12 Feb 2011 11:42:15 +0000
Message-ID: <1297510935.1770.38.camel@andybev>
References: <4D55A927.7060703@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter <netfilter@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4D55A927.7060703@genband.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-02-11 at 15:24 -0600, Chris Friesen wrote:
> It has been proposed to add a custom patch to clear the mark for all
> marked connections--is there a better way of doing this?
> 

How about using the conntrack userspace command-line interface?

conntrack -U -m 0

looks like it should do what you want.

Andy


