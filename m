From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] bridge: fdb: print NDA_SRC_VNI if available
Date: Wed, 1 Nov 2017 22:31:21 +0100
Message-ID: <20171101223121.2c60fa07@shemminger-XPS-13-9360>
References: <1509037975-6891-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:54232 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934251AbdKAVbs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 17:31:48 -0400
Received: by mail-lf0-f66.google.com with SMTP id l23so4055112lfk.10
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 14:31:47 -0700 (PDT)
In-Reply-To: <1509037975-6891-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Oct 2017 10:12:55 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

In general, this looks ok and I will apply it.

But why is there no ability to set source vni? The kernel accepts
it as a parameter to vxlan, but there is no option to set it with
ip command when creating vxlan.
