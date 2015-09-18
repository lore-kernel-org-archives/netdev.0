From: Sathya Perla <sathya.perla@avagotech.com>
Subject: Re: [PATCH net 4/5] be2net: allow offloading with the same port for
 IPv4 and IPv6
Date: Fri, 18 Sep 2015 09:00:15 +0530
Message-ID: <CAKvpyk3i7+q8JfV2b2+SgnYC-RAY5coFiVLaY1Pv-2nBPqW-6w@mail.gmail.com>
References: <cover.1442498316.git.jbenc@redhat.com>
	<1b2a27cefac4b736f098624b8c411aee6ccef9f2.1442498316.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Ajit Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:33195 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152AbbIRDaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 23:30:16 -0400
Received: by ykft14 with SMTP id t14so36065086ykf.0
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 20:30:15 -0700 (PDT)
In-Reply-To: <1b2a27cefac4b736f098624b8c411aee6ccef9f2.1442498316.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 7:41 PM, Jiri Benc <jbenc@redhat.com> wrote:
> The callback for adding vxlan port can be called with the same port for both
> IPv4 and IPv6. Do not disable the offloading if this occurs.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  drivers/net/ethernet/emulex/benet/be.h      |  1 +
>  drivers/net/ethernet/emulex/benet/be_main.c | 10 ++++++++++
>  2 files changed, 11 insertions(+)

Acked-by: Sathya Perla <sathya.perla@avagotech.com>

Thanks!
