From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 1/3] Use C99 style initializers everywhere
Date: Fri, 17 Jun 2016 09:34:01 -0700
Message-ID: <20160617093401.24ae66b1@xeon-e3>
References: <1466178968-27439-1-git-send-email-phil@nwl.cc>
	<1466178968-27439-2-git-send-email-phil@nwl.cc>
	<ddef688e6e3f4a1a895880de1f9f069d@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:36199 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751386AbcFQQeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 12:34:04 -0400
In-Reply-To: <ddef688e6e3f4a1a895880de1f9f069d@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Jun 2016 16:09:20 +0000
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Please have a look at commit 8f80d450c3cb ("tc: fix compilation with old gcc (< 4.6)") ...
> 
> Your changes effectively revert them again. Here, and some other parts of the bpf frontend
> code bits.


GCC 4.6 is 3 years old. So perhaps it is time to move on.
Maybe add a GCC version check in the makefile, to fail cleanly.
