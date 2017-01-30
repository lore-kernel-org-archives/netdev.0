From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v3 0/4] net: ipv6: Improve user experience with
 multipath routes
Date: Mon, 30 Jan 2017 12:07:43 +0100
Message-ID: <8f5334f0-20a3-0eb2-6baa-1fe8331ad2db@6wind.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
 <588D3EB9.1070107@cumulusnetworks.com>
 <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38849 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753137AbdA3LHx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 06:07:53 -0500
Received: by mail-wm0-f54.google.com with SMTP id r141so27972471wmg.1
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 03:07:52 -0800 (PST)
In-Reply-To: <592be6dc-df0e-6185-ba6f-5acf5d042ae5@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/01/2017 à 19:02, David Ahern a écrit :
[snip]
> Data centers are moving to L3, and multipath is a big part of that. Anyone who looks at ip -6 route enough knows it gets painful mentally pulling the individual routes into a single one.
I agree, but it's only an iproute2 problem. iproute2 could group routes to have
a better output, there is no need to have a kernel patch for this ;-)
