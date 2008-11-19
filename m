From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC PATCH 03/11] net: infrastructure for hardware time
	stamping
Date: Wed, 19 Nov 2008 16:21:03 +0100
Message-ID: <1227108063.16263.107.camel@ecld0pohly>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-2-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-3-git-send-email-patrick.ohly@intel.com>
	 <1227096528-24150-4-git-send-email-patrick.ohly@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24288 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753630AbYKSPVM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 10:21:12 -0500
In-Reply-To: <1227096528-24150-4-git-send-email-patrick.ohly@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-19 at 12:08 +0000, Ohly, Patrick wrote:
> +       struct sock_exterr_skb *serr;
[...]
> +       memset(serr, 0, sizeof(serr));

Before someone else mentions it: this was meant to be "sizeof(*serr)" of
course.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

