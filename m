From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Tue, 6 Oct 2015 12:21:24 -0700
Message-ID: <CALnjE+rk4d0bfsqu3KMhpYUDqYPzPYkA+ZqS5VU_J_GbAj5p4A@mail.gmail.com>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
	<20151005204020.56f50496@griffin>
	<CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
	<20151006175634.200d69a0@griffin>
	<CALnjE+pvenVjpyKHKjyqj-mWi9tgUtWs2mOUKhX1+O-0XkP3jQ@mail.gmail.com>
	<20151006204558.5f2f56fc@griffin>
	<CALnjE+ozN6CXTmhVjWiQLEUTL0Q8FJjPeO-H-zzoXKgvjcu2DA@mail.gmail.com>
	<20151006210358.65750aeb@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37742 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbbJFTVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 15:21:25 -0400
Received: by igcpe7 with SMTP id pe7so31942175igc.0
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 12:21:24 -0700 (PDT)
In-Reply-To: <20151006210358.65750aeb@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 6, 2015 at 12:03 PM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 6 Oct 2015 11:55:35 -0700, Pravin Shelar wrote:
>> We should be able to use lwtunnel devices on 4.3. How about using
>> tunnel device parameters to detect lwtunnel support. For example in
>> case of vxlan tunnel IFLA_VXLAN_COLLECT_METADATA flags can confirm
>> lwtunnel support.
>
> You would have to create the interface first using that flag and then
> check whether the created interface has the flag set or not. If not,
> delete the interface.
>
> Unfortunately, old kernels will just ignore the flag when creating the
> interface. That's why I wrote there's no useful way to check it.
>

It should report the flag when device parameters are requested by
userspace if there is support for lwtunnel. So check for the flag
should be good enough test for lwtunnel support. Why is that not
reliable check?
