From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 0/7] USB: don't recover device if suspend fails in system sleep
Date: Tue, 5 Mar 2013 13:14:08 +0800
Message-ID: <CACVXFVPn1Y+t-adOZDuiX1Zz4Jsj4OiD2TjOe+vT7fk3ZjFZQg@mail.gmail.com>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 5, 2013 at 12:01 PM, Ming Lei <ming.lei@canonical.com> wrote:
> Hi,
>
> This patch adds comments on interface driver suspend callback
> to emphasize that the failure return value is ignored by
> USB core in system sleep context, so do not try to recover
> device for this case, otherwise the URB traffic scheduled
> in recovery of failure path may cross system sleep, and may
> cause problems.
>
> Also fixes the USB serial, HID and several usbnet drivers
> which may recover device in suspend failure path of system sleep.

Sorry, this patches have compile problem, so please don't apply them,
and I will send v1 later.


Thanks,
--
Ming Lei
