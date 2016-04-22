From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 PATCH v3 1/1] tc: introduce IFE action
Date: Fri, 22 Apr 2016 10:00:47 -0700
Message-ID: <20160422100047.083055ee@xeon-e3>
References: <1461274814-16235-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33867 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937AbcDVRAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 13:00:36 -0400
Received: by mail-pf0-f174.google.com with SMTP id y69so24574952pfb.1
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 10:00:36 -0700 (PDT)
In-Reply-To: <1461274814-16235-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Apr 2016 17:40:14 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> new file mode 100644
> index 0000000..d648ff6
> --- /dev/null
> +++ b/include/linux/tc_ife.h
> @@ -0,0 +1,38 @@
> +#ifndef __UAPI_TC_IFE_H
> +#define __UAPI_TC_IFE_H
> +
> +#include <linux/types.h>
> +#include <linux/pkt_cls.h>
> +
> +#define TCA_ACT_IFE 25
> +/* Flag bits for now just encoding/decoding; mutually exclusive */
> +#define IFE_ENCODE 1
> +#define IFE_DECODE 0
> +
> +struct tc_ife {
> +	tc_gen;
> +	__u16 flags;
> +};
> +
> +/*XXX: We need to encode the total number of bytes consumed */
> +enum {
> +	TCA_IFE_UNSPEC,
> +	TCA_IFE_PARMS,
> +	TCA_IFE_TM,
> +	TCA_IFE_DMAC,
> +	TCA_IFE_SMAC,
> +	TCA_IFE_TYPE,
> +	TCA_IFE_METALST,
> +	__TCA_IFE_MAX
> +};
> +#define TCA_IFE_MAX (__TCA_IFE_MAX - 1)
> +
> +#define IFE_META_SKBMARK 1
> +#define IFE_META_HASHID 2
> +#define	IFE_META_PRIO 3
> +#define	IFE_META_QMAP 4
> +/*Can be overridden at runtime by module option*/
> +#define	__IFE_META_MAX 5
> +#define IFE_META_MAX (__IFE_META_MAX - 1)
> +
> +#endif

All header files for iproute2 (in include/linux) should come from santized kernel
headers. I do not see the file tc_ife.h in include/uapi/linux in current net-next
kernel source tree.
