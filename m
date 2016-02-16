From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net-next] net: l3mdev: address selection should only consider
 devices in L3 domain
Date: Tue, 16 Feb 2016 16:49:03 -0700
Message-ID: <56C3B56F.4020106@cumulusnetworks.com>
References: <1455663591-27615-1-git-send-email-dsa@cumulusnetworks.com>
 <20160216234115.GI659150@eidolon>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david@opensourcerouting.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34090 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933313AbcBPXtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 18:49:06 -0500
Received: by mail-io0-f169.google.com with SMTP id 9so7204124iom.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 15:49:06 -0800 (PST)
In-Reply-To: <20160216234115.GI659150@eidolon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/16 4:41 PM, David Lamparter wrote:
> ... this won't do enough.  If you look at the 4.3 patch I sent you, I
> was adding a comment:
>
> + /* For VRFs, the VRF device takes the place of the loopback device,
> +    with addresses on it being preferred.  Note in such cases the
> +    loopback device will be among the devices that fail the vrf_ifi
> +    equality check in the loop below.
> +  */
>

Sure, I was focused on fixing the 'ignore devices not in the VRF' but 
certainly for unnumbered use cases you want the VRF loopback address to 
be preferred. Missed that earlier.

Rather than spinning a patch on top of mine, fold this change into your 
and make it 1 patch to achieve the goal.
