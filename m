From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH] net: bridge: allow IPv6 when multicast flood is disabled
Date: Wed, 1 Mar 2017 09:57:07 +0000
Message-ID: <b6377d29-3dad-5671-8690-1fff04196723@brocade.com>
References: <1488215489-26372-1-git-send-email-mmanning@brocade.com>
 <E4A652DE-AC03-4E8D-B50E-8BE92DCA31C5@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "Stephen Hemminger" <stephen@networkplumber.org>,
        <bridge@lists.linux-foundation.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:58745 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751099AbdCAK0j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 05:26:39 -0500
In-Reply-To: <E4A652DE-AC03-4E8D-B50E-8BE92DCA31C5@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/02/17 09:20, Nikolay Aleksandrov wrote:
> We are aware of this and have discussed it, but I’m not sure this is the best way to fix it,
> it will still allow local IPv4 mcast to be flooded on all ports even with that flag removed and
> that definitely changes user-visible behaviour (even if it is okay) and will not be appropriate
> for -net.
> 
> Let me get back to you on this one.
> 
> Thanks,
>  Nik
> 
Thanks for your comments, I have sent a v2 patch accordingly in case you have no better suggestion.
We need per-port disabling of multicast flooding, but have to apply this patch to allow IPv6
connectivity so as to make it usable. There is no noteworthy impact on IPv4 as the fix only allows
packets originated by the device. As this feature is new to the 4.9 kernel, there are no backwards
compatibility issues with prior kernel versions if this fix is also applied to the 4.9 kernel.
