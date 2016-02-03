From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v5 1/2] ethtool: add speed/duplex validation
 functions
Date: Thu, 4 Feb 2016 10:32:26 +1100
Message-ID: <20160204103226.333d98ca@samsung9>
References: <1454468677-12280-1-git-send-email-razor@blackwall.org>
	<1454468677-12280-2-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, roopa@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35824 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbcBCXch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 18:32:37 -0500
Received: by mail-pf0-f174.google.com with SMTP id 65so22537226pfd.2
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 15:32:37 -0800 (PST)
In-Reply-To: <1454468677-12280-2-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  3 Feb 2016 04:04:36 +0100
Nikolay Aleksandrov <razor@blackwall.org> wrote:

>  
> +static inline int ethtool_validate_speed(__u32 speed)
> +{


No need for inline.

But why check for valid value at all. At some point in the
future, there will be yet another speed adopted by some standard body
and the switch statement would need another value.

Why not accept any value? This is a virtual device.
