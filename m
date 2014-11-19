From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: team: expose sysfs attributes for each team option
Date: Wed, 19 Nov 2014 10:45:28 -0800
Message-ID: <CAHA+R7OOnSfSP1uHrg=osH=+=sb-0Zj-=yYx8HXmpO95v+Dhyg@mail.gmail.com>
References: <93856491220bda9aede41a9571fb1ac1.squirrel@www.codeaurora.org>
	<20141117130201.GB1872@nanopsycho.orion>
	<03067d01f18e264b30f86d0307d11b07.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>
To: Hamad Kadmany <hkadmany@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:33721 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754559AbaKSSp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 13:45:29 -0500
Received: by mail-qa0-f49.google.com with SMTP id s7so812095qap.8
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 10:45:28 -0800 (PST)
In-Reply-To: <03067d01f18e264b30f86d0307d11b07.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2014 at 4:28 AM, Hamad Kadmany <hkadmany@codeaurora.org> wrote:
> On Mon, November 17, 2014 1:02 pm, Jiri Pirko wrote:
>>
>> Nak.
>>
>> I don't like this patch. The plan for team was keep things simple and to
>> have single userspace api using netlink, as that is the correct way to
>> deal with things. Sysfs for this use-case is not. Please, use netlink api.
>
> Using team driver requires using libnl3. In Android based platforms, libnl3 is not supported, and libnl3 license poses constraints in Android's user-space.
>

Check if libmnl fits your license:
http://www.netfilter.org/projects/libmnl/
