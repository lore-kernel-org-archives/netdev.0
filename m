From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Tue, 6 Oct 2015 17:56:34 +0200
Message-ID: <20151006175634.200d69a0@griffin>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
	<20151005204020.56f50496@griffin>
	<CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44462 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752700AbbJFP4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 11:56:38 -0400
In-Reply-To: <CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Oct 2015 12:37:50 -0700, Pravin Shelar wrote:
> That would involve lot of refactoring vxlan xmit code. I do not want
> to make such change in net tree at such late stage.

Fair enough. But then, the minimal fix for net.git would be just
modifying the current get_egress_tun_info handlers in vport-*.c,
wouldn't it? I'd say let's go this way and fix this properly for
net-next. See my other mail for my comments on the patch.

 Jiri

-- 
Jiri Benc
