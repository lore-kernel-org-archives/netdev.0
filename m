From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 4/8] af_unix: Allow SO_PEERCRED to work across namespaces.
Date: Mon, 14 Jun 2010 15:37:57 +0200
Message-ID: <4C1630B5.4000301@free.fr>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org> <m1r5kbgivt.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:52261 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006Ab0FNNiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 09:38:03 -0400
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate3.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o5EDc277010491
	for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 13:38:02 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5EDc2Kr1306762
	for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 14:38:02 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o5EDc1vM018294
	for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 14:38:02 +0100
In-Reply-To: <m1r5kbgivt.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2010 03:30 PM, Eric W. Biederman wrote:
> Use struct pid and struct cred to store the peer credentials on struct
> sock.  This gives enough information to convert the peer credential
> information to a value relative to whatever namespace the socket is in
> at the time.
>
> This removes nasty surprises when using SO_PEERCRED on socket
> connetions where the processes on either side are in different pid and
> user namespaces.
>
> Signed-off-by: Eric W. Biederman<ebiederm@xmission.com>
>    

Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>

