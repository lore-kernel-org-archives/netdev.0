From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before
 checking event type
Date: Fri, 17 Jan 2014 10:20:31 -0800
Message-ID: <20140117102031.00002a33@unknown>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63031 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752155AbaAQSUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 13:20:51 -0500
In-Reply-To: <1389959706-30976-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Jan 2014 12:55:06 +0100
Daniel Borkmann <dborkman@redhat.com> wrote:

> Jesse Brandeburg reported that commit acaf4e70997f caused a panic
> when adding a network namespace while vxlan module was present in
> the system:

I ran a quick test and the namespace issue no longer occurs once this
patch is applied.  As for this one vs Cong's, you guys can fight that
out.  Thanks for fixing this.

Tested-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
