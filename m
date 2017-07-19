From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 16/17] mlxsw: spectrum_router: Abort on
 source-specific routes
Date: Wed, 19 Jul 2017 19:36:16 +0300
Message-ID: <20170719163616.GA30613@splinter>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-17-jiri@resnulli.us>
 <a730169b-3f48-a232-0053-d2c40b5947e8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0055.outbound.protection.outlook.com ([104.47.1.55]:28832
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753465AbdGSQg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 12:36:27 -0400
Content-Disposition: inline
In-Reply-To: <a730169b-3f48-a232-0053-d2c40b5947e8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 19, 2017 at 10:16:19AM -0600, David Ahern wrote:
> On 7/19/17 1:02 AM, Jiri Pirko wrote:
> > From: Ido Schimmel <idosch@mellanox.com>
> > 
> > Without resorting to ACLs, the device performs route lookup solely based
> > on the destination IP address.
> > 
> > In case source-specific routing is needed, an error is returned and the
> > abort mechanism is activated, thus allowing the kernel to take over
> > forwarding decisions.
> > 
> > Instead of aborting, we can trap specific destination prefixes where
> > source-specific routes are present, but this will result in a lot more
> > code that is unlikely to ever be used.
> 
> Do you have a document summarizing these for users?

As you know, we've a Wiki we maintain for the features covered by mlxsw.
Once these patches are applied to net-next I intend to extend it with
IPv6 documentation and mention the above there.

I did a similar thing with inter-VRF routes:
https://github.com/Mellanox/mlxsw/wiki/Virtual-Routing-and-Forwarding-(VRF)#inter-vrf-routing
