From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 5/8] af_netlink: Add needed scm_destroy after scm_send.
Date: Tue, 15 Jun 2010 12:06:55 +0400
Message-ID: <4C17349F.6050309@openvz.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org> <m1ljajgiud.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:18036 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753142Ab0FOIIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 04:08:10 -0400
In-Reply-To: <m1ljajgiud.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2010 05:31 PM, Eric W. Biederman wrote:
> 
> scm_send occasionally allocates state in the scm_cookie, so I have
> modified netlink_sendmsg to guarantee that when scm_send succeeds
> scm_destory will be called to free that state.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Pavel Emelyanov <xemul@openvz.org>
