From: Cong Wang <cwang@twopensource.com>
Subject: Re: Fw: [Bug 79891] New: Router causes TCP retransmits for windows
 hosts after "ip_forward: fix inverted local_df test"
Date: Thu, 10 Jul 2014 10:11:04 -0700
Message-ID: <CAHA+R7N0ZgLfZNMrnHyRD+C=rGD86QXVkE0weLOLCM9npXMozg@mail.gmail.com>
References: <20140710064433.1fd17105@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:49264 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbaGJRLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 13:11:06 -0400
Received: by mail-la0-f50.google.com with SMTP id pv20so6542041lab.9
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 10:11:04 -0700 (PDT)
In-Reply-To: <20140710064433.1fd17105@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2014 at 6:44 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> After upgrading a router to Linux 3.2.60 most windows machines behind it
> started experiencing connection stalls. Downgrade to 3.2.59 resolved the
> problem. Using git bisect I pinpointed it to
> "59d9f389df3cdf72833d5ee17c3fe959b6bdc792 is the first bad commit", which
> entered the kernel from here
> http://marc.info/?l=linux-netdev&m=139949081418806&w=2
>

This commit should have been reverted for older kernels like 3.2.y.
