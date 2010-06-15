From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 4/8] af_unix: Allow SO_PEERCRED to work across namespaces.
Date: Tue, 15 Jun 2010 12:04:34 +0400
Message-ID: <4C173412.1070606@openvz.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org> <m1r5kbgivt.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47821 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755185Ab0FOIFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 04:05:45 -0400
In-Reply-To: <m1r5kbgivt.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2010 05:30 PM, Eric W. Biederman wrote:
> 
> Use struct pid and struct cred to store the peer credentials on struct
> sock.  This gives enough information to convert the peer credential
> information to a value relative to whatever namespace the socket is in
> at the time.
> 
> This removes nasty surprises when using SO_PEERCRED on socket
> connetions where the processes on either side are in different pid and
> user namespaces.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Pavel Emelyanov <xemul@openvz.org>
