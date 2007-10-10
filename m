From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Wed, 10 Oct 2007 12:15:33 -0600
Message-ID: <m1d4vmrg3e.fsf@ebiederm.dsl.xmission.com>
References: <470B71CD.3000706@openvz.org>
	<m1przoxk1v.fsf@ebiederm.dsl.xmission.com>
	<470C9384.9050102@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35915 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbXJJSQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 14:16:12 -0400
In-Reply-To: <470C9384.9050102@openvz.org> (Pavel Emelyanov's message of "Wed,
	10 Oct 2007 12:55:32 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@openvz.org> writes:

>> I know there are several data structures internal to the kernel that
>> are indexed by ifindex, and not struct net_device *.  There is the
>> iflink field in struct net_device.  We need a way to refer to network
>> devices in other namespaces in rtnetlink in an unambiguous way.   I
>> don't see any real problems with a global ifindex assignment until
>> we start migrating applications.
>> 
>> So please hold off on this until the kernel has been audited and
>> we have removed all of the uses of ifindex that assume ifindex is
>> global, that we can find.
>
> Ok.

Thanks.

Eric
