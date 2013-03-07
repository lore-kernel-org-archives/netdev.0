From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH v2 3/7] USBHID: don't recover device if suspend fails in
 system sleep
Date: Fri, 8 Mar 2013 00:16:08 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1303080013210.19460@pobox.suse.cz>
References: <1362672924-22975-1-git-send-email-ming.lei@canonical.com> <1362672924-22975-4-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1362672924-22975-4-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 8 Mar 2013, Ming Lei wrote:

> If suspend callback fails in system sleep context, usb core will
> ignore the failure and let the system sleep go ahead further, so this
> patch doesn't recover device under this situation, otherwise
> may cause resume() confused.
> 
> Cc: Jiri Kosina <jkosina@suse.cz>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>

Acked-by: Jiri Kosina <jkosina@suse.cz>

I guess this will go through USB tree as a series ...

Thanks,

-- 
Jiri Kosina
SUSE Labs
