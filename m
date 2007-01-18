From: Dmitry Mishin <dim@openvz.org>
Subject: Re: [PATCH 1/12] L2 network namespace (v3): current network namespace operations
Date: Thu, 18 Jan 2007 13:56:54 +0300
Message-ID: <200701181356.54986.dim@openvz.org>
References: <200701171851.14734.dim@openvz.org> <200701171857.40349.dim@openvz.org> <m1hcup8l4t.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, alexey@sw.ru, netdev@vger.kernel.org,
	saw@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:19215 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993AbXARK7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 05:59:23 -0500
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1hcup8l4t.fsf@ebiederm.dsl.xmission.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 17 January 2007 23:16, Eric W. Biederman wrote:
> Dmitry Mishin <dim@openvz.org> writes:
> 
> > Added functions and macros required to operate with network namespaces.
> > They are required in order to switch network namespace for incoming packets and
> > to not extend current network interface by additional network namespace argue.
> 
> Is exec_net only used in interrupt context?
I tried to do so.

> Or how do you ensure a sleeping function does not get called and the
> kernel process comes back on another cpu?
Seems that I forgot to remove it's usage at least in one place - in
clone_net_ns(). If you caught more, please, let me know. 

-- 
Thanks,
Dmitry.
