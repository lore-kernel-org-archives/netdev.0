From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 5/8] af_netlink: Add needed scm_destroy after scm_send.
Date: Mon, 14 Jun 2010 15:37:43 +0200
Message-ID: <4C1630A7.8000505@free.fr>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org> <m1ljajgiud.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([194.196.100.165]:58260 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753950Ab0FNNht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 09:37:49 -0400
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate5.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o5EDbmEY010664
	for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 13:37:48 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5EDbm84376996
	for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 14:37:48 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o5EDbl8M007927
	for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 14:37:48 +0100
In-Reply-To: <m1ljajgiud.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2010 03:31 PM, Eric W. Biederman wrote:
> scm_send occasionally allocates state in the scm_cookie, so I have
> modified netlink_sendmsg to guarantee that when scm_send succeeds
> scm_destory will be called to free that state.
>
> Signed-off-by: Eric W. Biederman<ebiederm@xmission.com>
> ---
>    

Reviewed-by: Daniel Lezcano <daniel.lezcano@free.fr>
