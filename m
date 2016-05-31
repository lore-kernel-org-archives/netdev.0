From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 3/5] bridge: add json support for
 bridge fdb show
Date: Tue, 31 May 2016 11:59:55 -0700
Message-ID: <20160531115955.4a45ff67@xeon-e3>
References: <1464410236-65044-4-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anuradhak@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, julien@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34146 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbcEaS7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 14:59:42 -0400
Received: by mail-pa0-f43.google.com with SMTP id bz2so44368245pad.1
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 11:59:41 -0700 (PDT)
In-Reply-To: <1464410236-65044-4-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 May 2016 21:37:14 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> Sample output:
> $bridge -j fdb show
> [{
>         "mac": "44:38:39:00:69:88",
>         "dev": "swp2s0",
>         "vlan": 2,
>         "master": "br0",
>         "state": "permanent"
>     },{
>         "mac": "00:02:00:00:00:01",
>         "dev": "swp2s0",
>         "vlan": 2,
>         "master": "br0"
>     },{
>         "mac": "00:02:00:00:00:02",
>         "dev": "swp2s1",
>         "vlan": 2,
>         "master": "br0"
>     },{
>         "mac": "44:38:39:00:69:89",
>         "dev": "swp2s1",
>         "master": "br0",
>         "state": "permanent"
>     },{
>         "mac": "44:38:39:00:69:89",
>         "dev": "swp2s1",
>         "vlan": 2,
>         "master": "br0",
>         "state": "permanent"
>     },{
>         "mac": "44:38:39:00:69:88",
>         "dev": "br0",
>         "master": "br0",
>         "state": "permanent"
>     }
>     ]

In most JSON I have seen, the output would be:

{
  "fdb" : [
     {
         "mac": "44:38:39:00:69:88",
         "dev": "swp2s0",
         "vlan": 2,
         "master": "br0",
         "state": "permanent"
     },
...
   ]
}

I.e never a bare array.
