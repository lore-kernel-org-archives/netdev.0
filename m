From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 net-next v4 0/5] bridge: json support for fdb
 and vlan show
Date: Wed, 22 Jun 2016 16:53:44 +0200
Message-ID: <20160622145344.GE2068@nanopsycho.orion>
References: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35862 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbcFVPHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 11:07:44 -0400
Received: by mail-wm0-f66.google.com with SMTP id c82so2087448wme.3
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 08:07:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 22, 2016 at 03:45:50PM CEST, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>This patch series adds json support for a few bridge show commands.
>We plan to follow up with json support for additional commands soon.

I'm just curious, what is you use case for this? Apps can use rtnetlink
socket directly.


>
>Anuradha Karuppiah (3):
>  json_writer: Removed automatic json-object type from the constructor
>  bridge: add json support for bridge fdb show
>  bridge: add json schema for bridge fdb show
>
>Roopa Prabhu (2):
>  bridge: add json support for bridge vlan show
>  bridge: update man page
>
>v2 - change vlan flags to an array as suggested by toshiaki
>
>v3 - no change. resubmitting as requested by stephen
>
>v4 - removed json type from constructor as recommended by stephen
>
> bridge/br_common.h            |   1 +
> bridge/bridge.c               |   5 +-
> bridge/fdb.c                  | 210 +++++++++++++++++++++++++++++++++---------
> bridge/vlan.c                 | 109 +++++++++++++++++++---
> lib/json_writer.c             |   6 +-
> man/man8/bridge.8             |   9 +-
> misc/ifstat.c                 |   7 ++
> misc/nstat.c                  |   6 ++
> schema/bridge_fdb_schema.json |  62 +++++++++++++
> 9 files changed, 352 insertions(+), 63 deletions(-)
> create mode 100644 schema/bridge_fdb_schema.json
>
>-- 
>1.9.1
>
