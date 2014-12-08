From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v5 0/3] remove bridge mode BRIDGE_MODE_SWDEV
Date: Mon, 8 Dec 2014 14:49:45 -0800
Message-ID: <CAE4R7bBUDQztn-Pk-xRxVJbGbnjE2_CnyDn3-k3PWPUu7mFJsw@mail.gmail.com>
References: <1418076261-24593-1-git-send-email-roopa@cumulusnetworks.com>
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
Received: from mail-wg0-f48.google.com ([74.125.82.48]:47175 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbaLHWtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 17:49:46 -0500
Received: by mail-wg0-f48.google.com with SMTP id y19so7397090wgg.35
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 14:49:45 -0800 (PST)
In-Reply-To: <1418076261-24593-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roopa, thanks for fixing this.  I'm a little lost on status of the
iproute2 patches related to this change and earlier changes.  Would
you and Jiri respin one set of iproute2 patches that gets us the final
answer?  It was getting a little messy with patches on top of
yet-to-be-accepted patches.  Thanks.

On Mon, Dec 8, 2014 at 2:04 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> BRIDGE_MODE_SWDEV was introduced to indicate switchdev offloads
> for bridging from user space (In other words to call into the hw switch
> port driver directly). But user can use existing BRIDGE_FLAGS_SELF
> to call into the hw switch port driver today. swdev mode is not required
> anymore. So, this patch removes it.
>
> v4 - v5
>     incorporate comments
>     - Define BRIDGE_MODE_UNDEF to handle cases where mode is not defined
>     - reverse the order of patches
>     - include patch comments in all patches
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Roopa Prabhu (3):
>   bridge: new mode flag to indicate mode 'undefined'
>   rocker: remove swdev mode
>   bridge: remove mode 'swdev'
>
>  drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
>  include/uapi/linux/if_bridge.h       |    2 +-
>  net/core/rtnetlink.c                 |   10 ++++++++--
>  3 files changed, 10 insertions(+), 20 deletions(-)
>
> --
> 1.7.10.4
>
