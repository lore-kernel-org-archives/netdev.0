From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3 2/2] iproute2: bridge vlan show new option to
 print ranges
Date: Sun, 25 Jan 2015 20:35:52 -0800
Message-ID: <CAE4R7bCR6YSK9J+OV+04w_UXWoSu56xSvHXkYkDzqP4Qudn76Q@mail.gmail.com>
References: <1422239185-14054-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:58769 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbbAZEfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 23:35:53 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so6933403wgh.6
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 20:35:52 -0800 (PST)
In-Reply-To: <1422239185-14054-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/bridge/bridge.c b/bridge/bridge.c
> index 5fcc552..88469ca 100644
> --- a/bridge/bridge.c
> +++ b/bridge/bridge.c
> @@ -21,6 +21,7 @@ int resolve_hosts;
>  int oneline = 0;
>  int show_stats;
>  int show_details;
> +int compress_vlans;
>  int timestamp;
>  char * _SL_ = NULL;
>
> @@ -32,7 +33,8 @@ static void usage(void)
>  "Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }\n"
>  "where  OBJECT := { link | fdb | mdb | vlan | monitor }\n"
>  "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] |\n"
> -"                    -o[neline] | -t[imestamp] | -n[etns] name }\n");
> +"                    -o[neline] | -t[imestamp] | -n[etns] name |\n"
> +"                    -c[ompressvlans] }\n");

This option is awkward at this level since it's specific to bridge vlan cmd.

Is it even necessary?  The real user of compressed vlans isn't the
"bridge show" cmd; just keep "bridge show" simple, listing each vlan
per line.
