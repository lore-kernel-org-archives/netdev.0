From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] ipv4: properly apply change to
 ignore_routes_on_linkdown to all interfaces
Date: Wed, 2 Mar 2016 13:46:32 -0500
Message-ID: <20160302184631.GA33942@gospo.home.greyhouse.net>
References: <1456936986-2042-1-git-send-email-gospo@cumulusnetworks.com>
 <56D72E2F.30207@cumulusnetworks.com>
 <20160302182827.GZ33942@gospo.home.greyhouse.net>
 <56D732A2.5080607@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35661 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756527AbcCBSqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:46:36 -0500
Received: by mail-qk0-f172.google.com with SMTP id o6so86339440qkc.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 10:46:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56D732A2.5080607@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2016 at 10:36:18AM -0800, David Ahern wrote:
> On 3/2/16 10:28 AM, Andy Gospodarek wrote:
> >>This seems wrong -- changing the 'all' and 'default' settings for a sysctl
> >>>should not require walking the interface list.
> >Not if you want to actually apply the config to all the interfaces.  If
> >you notice this borrows heavily from the sysctl to control ipv4
> >forwarding as it behaves in a manner that I would consider to be
> >proper.
> >
> 
> When the config is checked runtime it can look at 'all' and the setting for
> the individual interface; you don't have to walk the devices and apply the
> setting each time it is changed. See the keep_addr_on_down implementation.

Yes, I've seen that implemenation.  My interest was making sure that the
reported interface sysctl value was what was used AND it seems cleaner
to leave the ipv4 fib checks as-is since an additional clause in many of
those statements will make them even harder to read.  :-)
