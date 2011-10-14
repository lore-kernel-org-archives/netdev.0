From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: Disable LRO on FCoE or iSCSI boot
 device
Date: Fri, 14 Oct 2011 08:53:52 -0700
Message-ID: <C27F8246C663564A84BB7AB34397724266D2018303@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1318563481-19631-1-git-send-email-mchan@broadcom.com>
 <4E9855EC.1020509@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "'davem@davemloft.net'" <davem@davemloft.net>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "'Rick Jones'" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2471 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751550Ab1JNPyB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:54:01 -0400
In-Reply-To: <4E9855EC.1020509@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:

> Is this perhaps saying that a bnx2x-driven device being used for FCoE
> or
> iSCSI boot must not permit *any* run-time configuration change which
> leads to a NIC reset?
> 

That is right.  Unless you have a multipath configuration with multiple
ports, then you can reset one port at a time.
