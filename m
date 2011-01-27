From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] r8169: use RxFIFO overflow workaround for 8168c chipset
Date: Thu, 27 Jan 2011 12:27:30 +0100
Message-ID: <1296127650.8720.1.camel@ceranb.brq.redhat.com>
References: <1296127451-12640-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51280 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754368Ab1A0L1j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jan 2011 06:27:39 -0500
In-Reply-To: <1296127451-12640-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-01-27 at 12:24 +0100, Ivan Vecera wrote:
> I found that one of the 8168c chipsets (concretely XID 1c4000c0) starts
> generating RxFIFO overflow errors. The result is an infinite loop in
> interrupt handler as the RxFIFOOver is handled only for ...MAC_VER_11.
> With the workaround everything goes fine.
...of course starts generating RxFIFO overflow errors under very high
load. :-)

Ivan

