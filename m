From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] inetpeer: Add support for VRFs
Date: Sun, 23 Aug 2015 20:01:34 -0600
Message-ID: <55DA7AFE.5040301@cumulusnetworks.com>
References: <1440339964-16075-1-git-send-email-dsa@cumulusnetworks.com> <20150824001514.GD21926@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37980 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322AbbHXCBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 22:01:41 -0400
Received: by igfj19 with SMTP id j19so46629892igf.1
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 19:01:41 -0700 (PDT)
In-Reply-To: <20150824001514.GD21926@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/23/15 6:15 PM, Thomas Graf wrote:
> On 08/23/15 at 08:26am, David Ahern wrote:
>> inetpeer caches based on address only, so duplicate IP addresses within
>> a namespace return the same cached entry. Similar to IP fragments handle
>> duplicate addresses across VRFs by adding the VRF master device index to
>> the lookup.
>
> We have a lot of other places which use the address only. Are you
> going to add the VRF id to all these places as well?
>

If appropriate, yes. I have fixed IP fragments and this patch fixes 
inetpeer cache. In both cases (L3 artifacts) the vrf device index 
provides the means to uniquely identify duplicate IP addresses within a 
namespace. If you know of other code that might be impacted I will 
investigate and fix as needed.

Thanks,
David
