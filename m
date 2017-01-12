From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 v4 0/4] update ifstat for new stats
Date: Thu, 12 Jan 2017 16:32:31 +0100
Message-ID: <20170112163231.443f9205@griffin>
References: <1484228991-32999-1-git-send-email-nogahf@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        roszenrami@gmail.com, roopa@cumulusnetworks.com, jiri@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57514 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750899AbdALPcg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 10:32:36 -0500
In-Reply-To: <1484228991-32999-1-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jan 2017 15:49:47 +0200, Nogah Frankel wrote:
> Previously stats were gotten by RTM_GETLINK which returns 32 bits based
> statistics. It supports only one type of stats.
> Lately, a new method to get stats was added - RTM_GETSTATS. It supports
> ability to choose stats type. The basic stats were changed from 32 bits
> based to 64 bits based.
> 
> This patchset adds ifstat the ability to get extended stats by this
> method. Its adds two types of extended stats:
> 64bits - the same as the "normal" stats but get the stats from the cpu
> in 64 bits based struct.
> cpu_hits - for packets that hit cpu.

Please add also documentation to the respective man pages.

 Jiri
