From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 0/5] bridge: json support for fdb and
 vlan show
Date: Wed, 20 Jul 2016 12:07:11 -0700
Message-ID: <20160720120711.3a00a73e@xeon-e3>
References: <1464410236-65044-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anuradhak@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, julien@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33662 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754666AbcGTTHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 15:07:14 -0400
Received: by mail-pa0-f42.google.com with SMTP id ks6so20975211pab.0
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 12:07:14 -0700 (PDT)
In-Reply-To: <1464410236-65044-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 May 2016 21:37:11 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch series adds json support for a few bridge show commands.
> We plan to follow up with json support for additional commands soon.
> 
> Anuradha Karuppiah (3):
>   json_writer: allow base json data type to be array or object
>   bridge: add json support for bridge fdb show
>   bridge: add json schema for bridge fdb show
> 
> Roopa Prabhu (2):
>   bridge: add json support for bridge vlan show
>   bridge: update man page
> 
>  bridge/br_common.h            |   1 +
>  bridge/bridge.c               |   3 +
>  bridge/fdb.c                  | 201 +++++++++++++++++++++++++++++++++---------
>  bridge/vlan.c                 |  93 ++++++++++++++++++-
>  include/json_writer.h         |   5 +-
>  lib/json_writer.c             |  39 +++++++-
>  man/man8/bridge.8             |   9 +-
>  misc/ifstat.c                 |   6 +-
>  misc/lnstat.c                 |   2 +-
>  misc/nstat.c                  |   4 +-
>  schema/bridge_fdb_schema.json |  62 +++++++++++++
>  11 files changed, 365 insertions(+), 60 deletions(-)
>  create mode 100644 schema/bridge_fdb_schema.json
> 

Applied these for current release
