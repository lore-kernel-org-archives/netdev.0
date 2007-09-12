From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] [IPROUTE2] Add support for moving links between network namespaces
Date: Wed, 12 Sep 2007 08:06:08 -0600
Message-ID: <m1veag9dwv.fsf@ebiederm.dsl.xmission.com>
References: <m14pi0cac5.fsf@ebiederm.dsl.xmission.com>
	<m1zlzsavla.fsf@ebiederm.dsl.xmission.com>
	<m1veagavjr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6l4avhp.fsf_-_@ebiederm.dsl.xmission.com>
	<m1myvsavdn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ir6gava1.fsf_-_@ebiederm.dsl.xmission.com>
	<20070912153909.6b80448f@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Pavel Emelyanov <xemul@openvz.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:51990 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757543AbXILOHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 10:07:11 -0400
In-Reply-To: <20070912153909.6b80448f@oldman> (Stephen Hemminger's message of
	"Wed, 12 Sep 2007 15:39:09 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> On Wed, 12 Sep 2007 07:05:42 -0600
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> 
>> This adds support for setting the IFLA_NET_NS_PID attribute
>> on links allowing them to be moved between network namespaces.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>> ---
>>  include/linux/if_link.h |    1 +
>>  ip/iplink.c             |    9 +++++++++
>>  2 files changed, 10 insertions(+), 0 deletions(-)
>
> Please don't mix header file updates with command changes.
> As a first step, I always install standard kernel santized headers.

Sorry I didn't know.  Those changes are now in net-2.6.24
so installing sanitized headers should not change anything.

In please feel free to drop the if_link.h part, and if you want
I can resend that patch with those few lines deleted.

Eric
