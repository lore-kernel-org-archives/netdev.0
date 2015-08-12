From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 4/6] openvswitch: Use Geneve device.
Date: Wed, 12 Aug 2015 14:04:43 -0700
Message-ID: <CAEP_g=9n81RHv0ikFPAMqL94MnN8VGhSdY3L-+0mhk7cfqjSNQ@mail.gmail.com>
References: <1439356669-21814-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:33173 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbbHLVFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 17:05:07 -0400
Received: by lbbsx3 with SMTP id sx3so16636636lbb.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 14:05:03 -0700 (PDT)
In-Reply-To: <1439356669-21814-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 10:17 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> With help of tunnel metadata mode OVS can directly use
> Geneve devices to implement Geneve tunnels.
> This patch removes all of the OVS specific Geneve code
> and make OVS use a Geneve net_device. Basic geneve vport
> is still there to handle compatibility with current
> userspace application.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>
