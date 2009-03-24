From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Tue, 24 Mar 2009 08:27:33 -0700
Message-ID: <C27F8246C663564A84BB7AB34397724216584482DA@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20090324074213.GA4576@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Rick Jones" <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Bastian Blank'" <waldi@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2720 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760253AbZCXP1n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 11:27:43 -0400
In-Reply-To: <20090324074213.GA4576@wavehammer.waldi.eu.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bastian Blank wrote:

> What is the advantage of this? I always saw updates to more than one
> firmware at once in the past. The question is not: is it
> possible, but:
> it is necessary.
>

Looking at the git history, about 3 out of 7 times, bnx2_fw.h was
partially updated.  About 2 out of 8 times bnx2_fw2.h was partially
updated.  The next planned update for net-next is a partial update.

Either way will work.  Using separate files will reduce the amount
of patch churn during partial updates.  That's the advantage.

