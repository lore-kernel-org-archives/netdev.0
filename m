From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH 0/5] Backport to 3.10.y for fix CVE-2014-0181
Date: Fri, 13 Jun 2014 10:04:19 -0700
Message-ID: <CAHA+R7P8-Jw30h99PHhHw3G+Pe085VOtVo5h_noVHhZSV==BNA@mail.gmail.com>
References: <1402623070-26549-1-git-send-email-luxiangyu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: gregkh@linuxfoundation.org, stable@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Xiangyu Lu <luxiangyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:65029 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702AbaFMRFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2014 13:05:43 -0400
Received: by mail-qa0-f43.google.com with SMTP id k15so4077666qaq.16
        for <netdev@vger.kernel.org>; Fri, 13 Jun 2014 10:05:42 -0700 (PDT)
In-Reply-To: <1402623070-26549-1-git-send-email-luxiangyu@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2014 at 6:31 PM, Xiangyu Lu <luxiangyu@huawei.com> wrote:
> Hi Greg,
>     This backport fix CVE-2014-0181 which would still be vulnerable in
> the latest 3.10.y, please add it.

This is not how netdev works for stable. You need to check the
FAQ:

https://www.kernel.org/doc/Documentation/networking/netdev-FAQ.txt

Q: How can I tell what patches are queued up for backporting to the
   various stable releases?

A: Normally Greg Kroah-Hartman collects stable commits himself, but
   for networking, Dave collects up patches he deems critical for the
   networking subsystem, and then hands them off to Greg.
