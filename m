From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/2] [RFC] posix clock tuning
Date: Sat, 4 Sep 2010 12:23:55 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009041221240.888@router.home>
References: <cover.1283504065.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.prem.mail.ac4.yahoo.com ([76.13.13.46]:46412 "HELO
	smtp107.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754402Ab0IDRX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 13:23:58 -0400
In-Reply-To: <cover.1283504065.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 3 Sep 2010, Richard Cochran wrote:

> Recently on the lkml, we discussed how to allow adjustment of posix
> clocks. I have tried to understand and implement the ideas expressed
> in the various threads.
>
> If there is agreement on this approach, I will resubmit these two
> patches as part of a longer series, including support for a new kind
> of hardware clock, so you can see how it all fits together. But first,
> I would like to concentrate on the new syscall itself.
>
> The patches are against a recent net-next tree. Please don't worry if
> the syscall tables are not quite up to date. I can fix that later.

Could you explain why the existing interfaces are not sufficient that do
what you describe?

man adjtime
man adjtimex
man clock_settime
?

Why would you need this to support a new hardware clock? You want the
clock to run at a different speed from system time?

