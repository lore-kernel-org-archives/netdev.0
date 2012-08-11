From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 8/8] bridge: use list_for_each_entry() in netpoll
 functions
Date: Sat, 11 Aug 2012 11:07:33 -0700
Message-ID: <20120811110733.38905818@nehalam.linuxnetplumber.net>
References: <1344263012-4031-1-git-send-email-amwang@redhat.com>
	<1344263012-4031-9-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56673 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258Ab2HKSHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Aug 2012 14:07:44 -0400
In-Reply-To: <1344263012-4031-9-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  6 Aug 2012 22:23:32 +0800
Cong Wang <amwang@redhat.com> wrote:

> We don't delete 'p' from the list in the loop,
> so we can just use list_for_each_entry().
> 
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Good idea.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
