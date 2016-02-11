From: Sathya Perla <sathya.perla@broadcom.com>
Subject: Re: [PATCH net-next v2] be2net: don't report EVB for older chipsets
 when SR-IOV is disabled
Date: Thu, 11 Feb 2016 13:22:20 +0100
Message-ID: <CAKvpyk3RieXKNNXY-3G1h6=v+1+sN+b39gVMVaR1kvNZZr7O3A@mail.gmail.com>
References: <1455190946-2906-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Ajit Khaparde <ajit.khaparde@broadcom.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	Somnath Kotur <somnath.kotur@broadcom.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:36396 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbcBKMWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 07:22:20 -0500
Received: by mail-yw0-f177.google.com with SMTP id q190so37338311ywd.3
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 04:22:20 -0800 (PST)
In-Reply-To: <1455190946-2906-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 11, 2016 at 12:42 PM, Ivan Vecera <ivecera@redhat.com> wrote:
> The EVB (virtual bridge) functionality should be disabled on older BE3
> and Lancer chips if SR-IOV is disabled in the NIC's BIOS. This setting
> is identified by the zero value of total VFs reported by the card.
> The GET_HSW_CONFIG command cannot be used as it is not supported by
> these older chipset's FW.
>
> v2: added the comment

Acked-by: Sathya Perla <sathya.perla@broadcom.com>
