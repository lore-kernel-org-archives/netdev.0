From: Cong Wang <amwang@redhat.com>
Subject: Re: A performance regression of gretap
Date: Thu, 11 Jul 2013 10:15:10 +0800
Message-ID: <1373508910.12250.4.camel@cr0>
References: <327738182.1491147.1373450503005.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43567 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755063Ab3GKCPY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jul 2013 22:15:24 -0400
In-Reply-To: <327738182.1491147.1373450503005.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-10 at 06:01 -0400, Cong Wang wrote:
> 
> Could you please take a look? And, gre tunnel is fine, this
> problem only exists for gretap. I reviewed the gretap code,
> but can't find any bug.

After digging it a little bit, I found some of the packets on RX side
have incorrect TCP checksum after going through gretap, while the
packets captured on eth0 are all correct.

Thanks.
