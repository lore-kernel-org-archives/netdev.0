From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] vxlan: do real refcnt for vn_sock
Date: Wed, 29 May 2013 13:14:42 +0800
Message-ID: <1369804482.12227.17.camel@cr0>
References: <1369739242-5944-1-git-send-email-amwang@redhat.com>
	 <20130528214142.4e41db6f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56078 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751953Ab3E2FOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 01:14:50 -0400
In-Reply-To: <20130528214142.4e41db6f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-28 at 21:41 -0700, Stephen Hemminger wrote:
> Why not just fix the requirement to drop rtnl when calling igmp.
> The code comes out cleaner and safer as well.
> 

This could probably work too. Please submit it as a normal patch?
