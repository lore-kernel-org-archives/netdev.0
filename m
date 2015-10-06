From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Tue, 6 Oct 2015 21:03:58 +0200
Message-ID: <20151006210358.65750aeb@griffin>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
	<20151005204020.56f50496@griffin>
	<CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
	<20151006175634.200d69a0@griffin>
	<CALnjE+pvenVjpyKHKjyqj-mWi9tgUtWs2mOUKhX1+O-0XkP3jQ@mail.gmail.com>
	<20151006204558.5f2f56fc@griffin>
	<CALnjE+ozN6CXTmhVjWiQLEUTL0Q8FJjPeO-H-zzoXKgvjcu2DA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713AbbJFTEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 15:04:01 -0400
In-Reply-To: <CALnjE+ozN6CXTmhVjWiQLEUTL0Q8FJjPeO-H-zzoXKgvjcu2DA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Oct 2015 11:55:35 -0700, Pravin Shelar wrote:
> We should be able to use lwtunnel devices on 4.3. How about using
> tunnel device parameters to detect lwtunnel support. For example in
> case of vxlan tunnel IFLA_VXLAN_COLLECT_METADATA flags can confirm
> lwtunnel support.

You would have to create the interface first using that flag and then
check whether the created interface has the flag set or not. If not,
delete the interface.

Unfortunately, old kernels will just ignore the flag when creating the
interface. That's why I wrote there's no useful way to check it.

 Jiri

-- 
Jiri Benc
