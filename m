From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Wed, 7 Oct 2015 11:53:25 +0200
Message-ID: <20151007115325.60c077cc@griffin>
References: <CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
	<20151006175634.200d69a0@griffin>
	<CALnjE+pvenVjpyKHKjyqj-mWi9tgUtWs2mOUKhX1+O-0XkP3jQ@mail.gmail.com>
	<20151006204558.5f2f56fc@griffin>
	<CALnjE+ozN6CXTmhVjWiQLEUTL0Q8FJjPeO-H-zzoXKgvjcu2DA@mail.gmail.com>
	<20151006210358.65750aeb@griffin>
	<CALnjE+rk4d0bfsqu3KMhpYUDqYPzPYkA+ZqS5VU_J_GbAj5p4A@mail.gmail.com>
	<20151006213245.74810d81@griffin>
	<CALnjE+p2KQqZsgkHYsWrJfKUCev85eGH6TWdrQHTA-9KxO9tjQ@mail.gmail.com>
	<20151007100955.3f13120e@griffin>
	<20151007093401.GA28717@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pravin Shelar <pshelar@nicira.com>, netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457AbbJGJx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 05:53:29 -0400
In-Reply-To: <20151007093401.GA28717@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Oct 2015 11:34:01 +0200, Thomas Graf wrote:
> Extending ovs_dp_cmd_fill_info() to dump a new dp->kernel_features
> via a new Netlink attribtue which signals these capabilities looks
> like a straight forward way to solve this.
> 
> OVS just needs to set NLM_F_ECHO when creating the initial datapath.

Agreed. That's exactly what I'm trying to implement just now.

 Jiri

-- 
Jiri Benc
