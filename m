From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: netfilter: nf_conntrack_ipv4 does not show nf_nat as a user
Date: Tue, 06 Nov 2007 14:29:24 -0500
Message-ID: <4730C094.4070406@redhat.com>
References: <472F78C9.9060900@redhat.com> <472FB162.7050507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46198 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705AbXKFT30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 14:29:26 -0500
In-Reply-To: <472FB162.7050507@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/05/2007 07:12 PM, Patrick McHardy wrote:
> Chuck Ebbert wrote:
>> https://bugzilla.redhat.com/show_bug.cgi?id=333481#c3
>>
>> This is netfilter kernel problem. There is a usage count for the
>> conntrack_ipv4
>> module from the nf_nat module, which is not reported by lsmod.
>>   
> 
> This is "fixed" in the current kernel.

By this hack?

[NETFILTER]: Fix/improve deadlock condition on module removal netfilter

