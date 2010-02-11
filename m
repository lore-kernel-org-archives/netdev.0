From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and devices
 (v3)
Date: Thu, 11 Feb 2010 12:51:27 -0500
Message-ID: <4B74439F.20703@cs.columbia.edu>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com> <1265750713-15749-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brinza.cc.columbia.edu ([128.59.29.8]:39346 "EHLO
	brinza.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754864Ab0BKRvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 12:51:42 -0500
In-Reply-To: <1265750713-15749-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan,

You may also want to remove the limit of a single private
net-ns which is enforced in checkpoint.c:may_checkpoint_task().

Oren.


