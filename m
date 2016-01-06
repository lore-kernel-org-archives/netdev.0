From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch -next] mlxsw: core: remove an unnecessary condition
Date: Wed, 6 Jan 2016 11:15:47 +0100
Message-ID: <20160106101547.GB2295@nanopsycho.orion>
References: <20160106095630.GB23185@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37498 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbcAFKPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 05:15:49 -0500
Received: by mail-wm0-f49.google.com with SMTP id f206so68369494wmf.0
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 02:15:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160106095630.GB23185@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 06, 2016 at 10:56:30AM CET, dan.carpenter@oracle.com wrote:
>We checked "err" on the lines before so we know it's zero here.
>
>These cause a static checker warning because checking known things can
>indicate a bug.  Maybe there is a missing assignment or we are checking
>the wrong variable.
>
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
