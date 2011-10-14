From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] bnx2x: Disable LRO on FCoE or iSCSI boot device
Date: Fri, 14 Oct 2011 08:31:56 -0700
Message-ID: <4E9855EC.1020509@hp.com>
References: <1318563481-19631-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, dmitry@broadcom.com,
	eilong@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:23668 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933232Ab1JNPb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:59 -0400
In-Reply-To: <1318563481-19631-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2011 08:38 PM, Michael Chan wrote:
> From: Dmitry Kravkov<dmitry@broadcom.com>
>
> For an FCoE or iSCSI boot device, the networking side must stay "up" all
> the time.  Otherwise, the FCoE/iSCSI interface driven by bnx2i/bnx2fc
> will be reset and we'll lose the root file system.
>
> If LRO is enabled, scripts that enable IP forwarding or bridging will
> disable LRO and cause the device to be reset.  Disabling LRO on these
> boot devices will prevent the reset.

Is this perhaps saying that a bnx2x-driven device being used for FCoE or 
iSCSI boot must not permit *any* run-time configuration change which 
leads to a NIC reset?

rick jones
