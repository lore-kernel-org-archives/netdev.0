From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] RDS: minor updates for net-next
Date: Fri, 30 Oct 2009 12:23:26 -0700 (PDT)
Message-ID: <20091030.122326.73781593.davem@davemloft.net>
References: <1256928893-17844-1-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com
To: andy.grover@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59411
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757372AbZJ3TXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 15:23:03 -0400
In-Reply-To: <1256928893-17844-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Grover <andy.grover@oracle.com>
Date: Fri, 30 Oct 2009 11:54:52 -0700

> These patches fix some small issues with RDS, please review and
> apply if ok.

Adding new socket options is not appropriate for -rc* series
submissions.

The changes that fix races and panics are fine, the rest is not.

Please respin your changes properly for net-2.6, and we can add the
socket option and do the other stuff in net-next-2.6

Thanks.
