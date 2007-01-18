From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/12] L2 network namespace (v3): current network namespace operations
Date: Thu, 18 Jan 2007 06:37:39 -0700
Message-ID: <m1ejps78ws.fsf@ebiederm.dsl.xmission.com>
References: <200701171851.14734.dim@openvz.org>
	<200701171857.40349.dim@openvz.org>
	<m1hcup8l4t.fsf@ebiederm.dsl.xmission.com>
	<200701181356.54986.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, alexey@sw.ru, netdev@vger.kernel.org,
	saw@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:44650 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932348AbXARNiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jan 2007 08:38:51 -0500
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200701181356.54986.dim@openvz.org> (Dmitry Mishin's message of
	"Thu, 18 Jan 2007 13:56:54 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin <dim@openvz.org> writes:

> On Wednesday 17 January 2007 23:16, Eric W. Biederman wrote:
>> Dmitry Mishin <dim@openvz.org> writes:
>> 
>> > Added functions and macros required to operate with network namespaces.
>> > They are required in order to switch network namespace for incoming packets
> and
>> > to not extend current network interface by additional network namespace
> argue.
>> 
>> Is exec_net only used in interrupt context?
> I tried to do so.
>
>> Or how do you ensure a sleeping function does not get called and the
>> kernel process comes back on another cpu?
> Seems that I forgot to remove it's usage at least in one place - in
> clone_net_ns(). If you caught more, please, let me know. 

Sure.  It was not clear from what I saw of the patch it was intended to
be restricted to only interrupt context.  So if figured I would ask if
that was what you meant.

Eric
