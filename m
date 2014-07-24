From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 1/3] ipv4: fail early when creating netdev named
 all or default
Date: Thu, 24 Jul 2014 10:41:46 -0700
Message-ID: <CAM_iQpUs3Js2Gjmmj+dEMxQTHOQFSEZCyos=1b=peU4-3Rf5vg@mail.gmail.com>
References: <1406153852-22511-1-git-send-email-xiyou.wangcong@gmail.com>
	<1406153852-22511-2-git-send-email-xiyou.wangcong@gmail.com>
	<CAGVrzcbnEkN1gsUVZBYvtRLdYEGtTZnYATG0oVAKJjWHyfGU0w@mail.gmail.com>
	<20140724030054.GB2978@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Stephane Chazelas <stephane.chazelas@gmail.com>,
	David Miller <davem@davemloft.net>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:43189 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932857AbaGXRlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 13:41:47 -0400
Received: by mail-oa0-f53.google.com with SMTP id j17so4000963oag.26
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 10:41:47 -0700 (PDT)
In-Reply-To: <20140724030054.GB2978@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 8:00 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Wed, Jul 23, 2014 at 06:05:07PM -0700, Florian Fainelli wrote:
>>
>> Since this exact same check is done in the ipv6 counterpart, how about
>> moving this to a helper function like: sysctl_dev_name_is_allowed()
>> such that you centralize where the naming policy is enforced? In case
>> we need to blacklist some other interface names, there should be one
>> place to update.
>
> Agree that a common function would be useful.
>
> There also might be cases where one would want to impose more limits
> than just what is limited based on /proc, so this may be something to consider
> in core networking code.

I agree generally, just that I think each protocol should be free to define
its own limit on names, not just "all" and "default".

Anyway, I will wait for other feedback, especially from David,
and update the patch.

Thanks.
