From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net] net:ethernet:aquantia: Fix for RX checksum offload.
Date: Wed, 22 Mar 2017 17:02:31 -0400
Message-ID: <08233f4d-1df6-25de-387c-346978f37e35@redhat.com>
References: <cc4fcad0ba1a6e7ae7c55cd15fe0b4e23650c04e.1490203234.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David Arcari <darcari@redhat.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49364 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932608AbdCVVCj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 17:02:39 -0400
In-Reply-To: <cc4fcad0ba1a6e7ae7c55cd15fe0b4e23650c04e.1490203234.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-03-22 1:21 PM, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
>
> Since AQC-100/107/08 chips supports hardware checksums for RX we should indicate
> this via NETIF_F_RXCSUM flag.

Looks good, and fixes an lnst netperf test failure.

Acked-by: Jarod Wilson <jarod@redhat.com>

-- 
Jarod Wilson
jarod@redhat.com
