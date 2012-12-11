From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: ethtool: Add destination MAC address to
 flow steering API
Date: Tue, 11 Dec 2012 21:55:22 +0200
Message-ID: <CAJZOPZJfqdrxKp8ZPTXs_-07XSdPoKu+bNQNZzkeTRgP-R2XnQ@mail.gmail.com>
References: <1355227436-18383-1-git-send-email-amirv@mellanox.com>
	<1355227436-18383-2-git-send-email-amirv@mellanox.com>
	<50C76F6E.2010600@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yan Burman <yanb@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:63978 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753226Ab2LKUCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 15:02:43 -0500
Received: by mail-ie0-f171.google.com with SMTP id 17so16785617iea.16
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 12:02:43 -0800 (PST)
In-Reply-To: <50C76F6E.2010600@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 11, 2012 at 7:37 PM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
>
> Is there any special reason why you need to change the size of this
> structure?  It seems like you could probably just replace the data
> section with a union containing either 8 bytes of user specified data or
> your MAC address data.  Then we wouldn't need all of the changes to the
> rest of the flow specifier.


basically, we followed Ben's suggestions made here
http://marc.info/?t=134977576500003
