From: Martin Lau <kafai@fb.com>
Subject: [Question]: Details on TCP_INFO extension
Date: Thu, 12 Mar 2015 10:58:38 -0700
Message-ID: <20150312175837.GE1032293@devbig242.prn2.facebook.com>
References: <54E661BF.4020404@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: rapier <rapier@psc.edu>, Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: <tcpinst-wg@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56507 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754162AbbCLR6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 13:58:46 -0400
Content-Disposition: inline
In-Reply-To: <54E661BF.4020404@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Old Title: [Tcpinst-wg] Welcome to the TCP Instrumentation List

On Thu, Feb 19, 2015 at 05:20:47PM -0500, rapier wrote:
> There should be two sets of instruments. Operational and diagnostic. The 
> operation instruments will be be used to extend TCP_INFO and will always 
> be available. Google will be providing a patch for upstream with 8 
> instruments in this category. The diagnostic instruments will be enabled 
> by the user on an as needed basis. These data from these instruments 
> will be stored in a separate structure that is referenced by a pointer 
> in the socket or some other mechanism. The ability to only enable a 
> subset of these instruments should be a design goal.
Can Google share which 8 fields will be added to TCP_INFO?

Thanks,
--Martin
