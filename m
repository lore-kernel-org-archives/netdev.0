From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 04/10] net: Refactor vxlan driver to make use of common
 UDP tunnel functions
Date: Thu, 24 Jul 2014 09:46:24 +0300
Message-ID: <CAJZOPZ+fMJRJ5QYSMZzOepw3dg2HcTnV=LtDAwsV-PA=uP71vg@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
	<1406024393-6778-5-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:55378 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbaGXGqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 02:46:25 -0400
Received: by mail-qg0-f44.google.com with SMTP id e89so2782312qgf.31
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 23:46:24 -0700 (PDT)
In-Reply-To: <1406024393-6778-5-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2014 at 1:19 PM, Andy Zhou <azhou@nicira.com> wrote:

> @@ -105,6 +105,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
>                 err = -EINVAL;
>                 goto error;
>         }
> +
>         a = nla_find_nested(options, OVS_TUNNEL_ATTR_DST_PORT);
>         if (a && nla_len(a) == sizeof(u16)) {
>                 dst_port = nla_get_u16(a);

blank line added by mistake?
