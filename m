From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Tue, 6 Oct 2015 14:16:02 -0700
Message-ID: <CALnjE+p2KQqZsgkHYsWrJfKUCev85eGH6TWdrQHTA-9KxO9tjQ@mail.gmail.com>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
	<20151005204020.56f50496@griffin>
	<CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
	<20151006175634.200d69a0@griffin>
	<CALnjE+pvenVjpyKHKjyqj-mWi9tgUtWs2mOUKhX1+O-0XkP3jQ@mail.gmail.com>
	<20151006204558.5f2f56fc@griffin>
	<CALnjE+ozN6CXTmhVjWiQLEUTL0Q8FJjPeO-H-zzoXKgvjcu2DA@mail.gmail.com>
	<20151006210358.65750aeb@griffin>
	<CALnjE+rk4d0bfsqu3KMhpYUDqYPzPYkA+ZqS5VU_J_GbAj5p4A@mail.gmail.com>
	<20151006213245.74810d81@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35936 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbbJFVQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 17:16:04 -0400
Received: by ioii196 with SMTP id i196so1168474ioi.3
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 14:16:03 -0700 (PDT)
In-Reply-To: <20151006213245.74810d81@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 6, 2015 at 12:32 PM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 6 Oct 2015 12:21:24 -0700, Pravin Shelar wrote:
>> It should report the flag when device parameters are requested by
>> userspace if there is support for lwtunnel. So check for the flag
>> should be good enough test for lwtunnel support. Why is that not
>> reliable check?
>
> Which device? You'll need to create one before querying it. Which won't
> work so nicely for older kernels. Basically, what the user space would
> have to do is trying to create a vxlan interface and then deleting it
> and going the tunnel vport way. It can be quite confusing, I'm afraid.
>

When OVS needs to add a vxlan tunnel device, OVS can create the vxlan
device and check the parameters for the flag. If the flag does not
exist then fallback to vport-create. This only needs to be done for
very first tunnel device. Thats how most of features are supported in
OVS.
Sorry, but I do not see where is the confusion.
