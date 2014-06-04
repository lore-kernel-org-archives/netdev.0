From: Alex <d77190@mail.ru>
Subject: Re: Bug 75571
Date: Wed, 04 Jun 2014 15:31:32 +0700
Message-ID: <1401870692.29664.1.camel@anpws>
References: <1401085231.1775.9.camel@anpws>
	 <CAHA+R7Oog=fAGjcfVTus2HdCt_Vv-1XDFePR3mLb0FM1N3q0ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxnat3.880.ru ([194.8.85.227]:61602 "EHLO stk-gw0.880.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751139AbaFDIbU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 04:31:20 -0400
In-Reply-To: <CAHA+R7Oog=fAGjcfVTus2HdCt_Vv-1XDFePR3mLb0FM1N3q0ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Could you try the following patch? We need to call skb_cow_head() before
> skb_push().
This patch solves problem, no panic or any error messages.
Thank you.
