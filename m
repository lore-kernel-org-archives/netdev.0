From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] [IPROUTE2] Add support for moving links between network
 namespaces
Date: Wed, 12 Sep 2007 15:39:09 +0200
Message-ID: <20070912153909.6b80448f@oldman>
References: <m14pi0cac5.fsf@ebiederm.dsl.xmission.com>
	<m1zlzsavla.fsf@ebiederm.dsl.xmission.com>
	<m1veagavjr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6l4avhp.fsf_-_@ebiederm.dsl.xmission.com>
	<m1myvsavdn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ir6gava1.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Pavel Emelyanov <xemul@openvz.org>,
	Patrick McHardy <kaber@trash.net>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41879 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965613AbXILNi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:38:27 -0400
In-Reply-To: <m1ir6gava1.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Sep 2007 07:05:42 -0600
ebiederm@xmission.com (Eric W. Biederman) wrote:

> 
> This adds support for setting the IFLA_NET_NS_PID attribute
> on links allowing them to be moved between network namespaces.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  include/linux/if_link.h |    1 +
>  ip/iplink.c             |    9 +++++++++
>  2 files changed, 10 insertions(+), 0 deletions(-)

Please don't mix header file updates with command changes.
As a first step, I always install standard kernel santized headers.
