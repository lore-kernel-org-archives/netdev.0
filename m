From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH openvswitch] linux: Signal datapath that unaligned Netlink
 message can be received
Date: Mon, 25 Nov 2013 15:41:47 -0800
Message-ID: <CAEP_g=9Ax4A+eKZyUXhZhqFQ8Nyi5JeQzwyqJY=rVceKZHEHNw@mail.gmail.com>
References: <48c93fb3c82bca0c9858ff528e2cf79d72d76082.1385057672.git.tgraf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:50019 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753606Ab3KYXmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 18:42:10 -0500
Received: by mail-lb0-f181.google.com with SMTP id q8so3730651lbi.26
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 15:42:07 -0800 (PST)
In-Reply-To: <48c93fb3c82bca0c9858ff528e2cf79d72d76082.1385057672.git.tgraf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 21, 2013 at 10:15 AM, Thomas Graf <tgraf@redhat.com> wrote:
> diff --git a/lib/dpif-linux.c b/lib/dpif-linux.c
> index 1dcf321..5c952bc 100644
> --- a/lib/dpif-linux.c
> +++ b/lib/dpif-linux.c
> @@ -232,6 +233,7 @@ dpif_linux_open(const struct dpif_class *class OVS_UNUSED, const char *name,
>          dp_request.cmd = OVS_DP_CMD_GET;
>      }
>      dp_request.name = name;
> +    dp_request.user_features |= OVS_DP_F_UNALIGNED;

Should we restrict this to just OVS_DP_CMD_NEW?
