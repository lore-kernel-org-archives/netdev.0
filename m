From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] fix reuseaddr regression
Date: Fri, 22 Sep 2017 20:40:45 -0700 (PDT)
Message-ID: <20170922.204045.1198472539959809091.davem@davemloft.net>
References: <1506126008-9148-1-git-send-email-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        linux-kernel@vger.kernel.org
To: josef@toxicpanda.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506126008-9148-1-git-send-email-josef@toxicpanda.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josef Bacik <josef@toxicpanda.com>
Date: Fri, 22 Sep 2017 20:20:05 -0400

> I introduced a regression when reworking the fastreuse port stuff that allows
> bind conflicts to occur once a reuseaddr successfully opens on an existing tb.
> The root cause is I reversed an if statement which caused us to set the tb as if
> there were no owners on the socket if there were, which obviously is not
> correct.
> 
> Dave could you please queue these changes up for -stable, I've run them through
> the net tests and added another test to check for this problem specifically.

Series applied and queued up for -stable, thanks.
