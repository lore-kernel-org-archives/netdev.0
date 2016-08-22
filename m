From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v05 21/72] include/uapi/linux/if_pppox.h: include
 linux/if.h
Date: Mon, 22 Aug 2016 16:26:41 -0700 (PDT)
Message-ID: <20160822.162641.227249250583935243.davem@davemloft.net>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
        <1471890809-4383-22-git-send-email-mikko.rapeli@iki.fi>
        <20160822123745.7921a88d@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mikko.rapeli@iki.fi, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160822123745.7921a88d@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 22 Aug 2016 12:37:45 -0700

> It seems your goal is that every include file should be standalone,
> i.e it must include every definition it uses.

I think this is absolutely mandatory Stephen.  If you include x.h
it should just work if you use the interfaces x.h defines.

No user should have to know about dependencies, that is exactly the
job of the header file itself.
