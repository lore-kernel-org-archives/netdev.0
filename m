From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Tue, 6 Oct 2015 21:32:45 +0200
Message-ID: <20151006213245.74810d81@griffin>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
	<20151005204020.56f50496@griffin>
	<CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
	<20151006175634.200d69a0@griffin>
	<CALnjE+pvenVjpyKHKjyqj-mWi9tgUtWs2mOUKhX1+O-0XkP3jQ@mail.gmail.com>
	<20151006204558.5f2f56fc@griffin>
	<CALnjE+ozN6CXTmhVjWiQLEUTL0Q8FJjPeO-H-zzoXKgvjcu2DA@mail.gmail.com>
	<20151006210358.65750aeb@griffin>
	<CALnjE+rk4d0bfsqu3KMhpYUDqYPzPYkA+ZqS5VU_J_GbAj5p4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35132 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752995AbbJFTct (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 15:32:49 -0400
In-Reply-To: <CALnjE+rk4d0bfsqu3KMhpYUDqYPzPYkA+ZqS5VU_J_GbAj5p4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Oct 2015 12:21:24 -0700, Pravin Shelar wrote:
> It should report the flag when device parameters are requested by
> userspace if there is support for lwtunnel. So check for the flag
> should be good enough test for lwtunnel support. Why is that not
> reliable check?

Which device? You'll need to create one before querying it. Which won't
work so nicely for older kernels. Basically, what the user space would
have to do is trying to create a vxlan interface and then deleting it
and going the tunnel vport way. It can be quite confusing, I'm afraid.

 Jiri

-- 
Jiri Benc
