From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: vethpair creation performance, 3.14 versus 4.2.0
Date: Mon, 31 Aug 2015 15:29:44 -0600
Message-ID: <55E4C748.1070300@cumulusnetworks.com>
References: <55E4AF74.7030107@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Rick Jones <rick.jones2@hp.com>,
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38729 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbbHaV3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 17:29:47 -0400
Received: by igbuu8 with SMTP id uu8so35517544igb.1
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 14:29:46 -0700 (PDT)
In-Reply-To: <55E4AF74.7030107@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/31/15 1:48 PM, Rick Jones wrote:
> My attempts to get a call-graph have been met with very limited success.
>   Even though I've installed the dbg package from "make deb-pkg" the
> symbol resolution doesn't seem to be working.

Looks like Debian does not enable framepointers by default:

$ grep FRAME /boot/config-3.2.0-4-amd64
...
# CONFIG_FRAME_POINTER is not set

Similar result for jessie.
