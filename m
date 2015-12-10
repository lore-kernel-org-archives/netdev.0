From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] route: ignore RTAX_HOPLIMIT of value -1
Date: Thu, 10 Dec 2015 08:48:46 -0800
Message-ID: <20151210084846.5f31b140@xeon-e3>
References: <564c2ede04884ee5905825d6363107a2@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:34786 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751860AbbLJQsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 11:48:42 -0500
In-Reply-To: <564c2ede04884ee5905825d6363107a2@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Dec 2015 12:50:22 +0000
Phil Sutter <phil@nwl.cc> wrote:

> Older kernels use -1 internally as indicator to use the sysctl default,
> but they still export the setting. Newer kernels use 0 to indicate that
> (which is why the conversion from -1 to 0 was done here), but they also
> stopped exporting the value. Since the meaning of -1 is clear, treat it
> equally like default on newer kernels (which is to not print anything).
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/iproute.c | 17 ++++++++---------
>  1 file changed, 8 insertions(+), 9 deletions(-)

Applied, thanks
