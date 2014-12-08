From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v5 1/3] bridge: new mode flag to indicate mode 'undefined'
Date: Mon, 8 Dec 2014 14:43:55 -0800
Message-ID: <CAE4R7bDDSN+hd_rcd0FySBHzpb7XDaKQ8F=_eSN0NXt7GykQCQ@mail.gmail.com>
References: <1418076261-24593-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:54950 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbaLHWn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 17:43:57 -0500
Received: by mail-wg0-f42.google.com with SMTP id z12so7446914wgg.15
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 14:43:55 -0800 (PST)
In-Reply-To: <1418076261-24593-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>

On Mon, Dec 8, 2014 at 2:04 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch adds mode BRIDGE_MODE_UNDEF for cases where mode is not needed.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> ---
>  include/uapi/linux/if_bridge.h |    1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
> index 296a556..05f0869 100644
> --- a/include/uapi/linux/if_bridge.h
> +++ b/include/uapi/linux/if_bridge.h
> @@ -106,6 +106,7 @@ struct __fdb_entry {
>  #define BRIDGE_MODE_VEB                0       /* Default loopback mode */
>  #define BRIDGE_MODE_VEPA       1       /* 802.1Qbg defined VEPA mode */
>  #define BRIDGE_MODE_SWDEV      2       /* Full switch device offload */
> +#define BRIDGE_MODE_UNDEF      0xFFFF  /* mode undefined */
>
>  /* Bridge management nested attributes
>   * [IFLA_AF_SPEC] = {
> --
> 1.7.10.4
>
