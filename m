From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] ipv4: properly apply change to
 ignore_routes_on_linkdown to all interfaces
Date: Wed, 2 Mar 2016 10:36:18 -0800
Message-ID: <56D732A2.5080607@cumulusnetworks.com>
References: <1456936986-2042-1-git-send-email-gospo@cumulusnetworks.com>
 <56D72E2F.30207@cumulusnetworks.com>
 <20160302182827.GZ33942@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34560 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbcCBSgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:36:21 -0500
Received: by mail-pf0-f175.google.com with SMTP id 4so59947139pfd.1
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 10:36:20 -0800 (PST)
In-Reply-To: <20160302182827.GZ33942@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/16 10:28 AM, Andy Gospodarek wrote:
>> This seems wrong -- changing the 'all' and 'default' settings for a sysctl
>> >should not require walking the interface list.
> Not if you want to actually apply the config to all the interfaces.  If
> you notice this borrows heavily from the sysctl to control ipv4
> forwarding as it behaves in a manner that I would consider to be
> proper.
>

When the config is checked runtime it can look at 'all' and the setting 
for the individual interface; you don't have to walk the devices and 
apply the setting each time it is changed. See the keep_addr_on_down 
implementation.
