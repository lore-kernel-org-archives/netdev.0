From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH iproute2] vxlan: add missing dst port setup option
Date: Sat, 11 Jan 2014 00:39:08 +0100
Message-ID: <52D0849C.60203@redhat.com>
References: <1389268586-3205-1-git-send-email-dborkman@redhat.com> <20140110153654.2548f143@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291AbaAJXjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 18:39:14 -0500
In-Reply-To: <20140110153654.2548f143@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2014 12:36 AM, Stephen Hemminger wrote:
> On Thu,  9 Jan 2014 12:56:26 +0100
> Daniel Borkmann <dborkman@redhat.com> wrote:
>
>> Kernel commit 823aa873bc ("vxlan: allow choosing destination port
>> per vxlan") and 553675fb5e ("vxlan: listen on multiple ports")
>> make it "now possible to define the same virtual network id but
>> with different UDP port values which can be useful for migration."
>>
>> However, IFLA_VXLAN_PORT netlink attribute was available in the
>> kernel but hasn't been pushed to iproute2 in order to make use
>> of it, hence, add this option so that people can use it.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   ip/iplink_vxlan.c     | 17 ++++++++++++++++-
>>   man/man8/ip-link.8.in |  6 ++++++
>>   2 files changed, 22 insertions(+), 1 deletion(-)
>>
>
> I restored the older version of IFLA_VXLAN_PORT stuff that was reverted
> because that option was broken on 3.10.

Ok, that's fine, thanks Stephen!
