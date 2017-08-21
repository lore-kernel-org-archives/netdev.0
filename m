From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH 4/6] mpls: VPLS support
Date: Mon, 21 Aug 2017 18:11:52 +0200
Message-ID: <58135789-121b-088f-740a-8e10304ebbd1@6wind.com>
References: <20170816170202.456851-1-equinox@diac24.net>
 <20170816170202.456851-5-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com
To: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:35698 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753900AbdHUQMC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 12:12:02 -0400
Received: by mail-wr0-f176.google.com with SMTP id k46so28602448wre.2
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 09:12:01 -0700 (PDT)
In-Reply-To: <20170816170202.456851-5-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Is it right to put vpls.c file in /net/mpls, I know it's depends 
essentially from the mpls stack, but vpls is a driver so moving it in 
/drivers/net should be cleaner but we have to export some mpls functions.

Let's see others opinion.

On 08/16/2017 07:02 PM, David Lamparter wrote:
> [work-in-progress, works but needs changes]
> [v2: refactored lots of things, e.g. dst_metadata, no more genetlink]
