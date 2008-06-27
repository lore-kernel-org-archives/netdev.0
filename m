From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] e1000: make ioport free
Date: Fri, 27 Jun 2008 02:08:31 -0400
Message-ID: <486483DF.5060404@garzik.org>
References: <485B1B8E.1060108@jp.fujitsu.com> <485B1C31.4020507@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>,
	auke-jan.h.kok@intel.com
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756949AbYF0GJp@vger.kernel.org>
In-Reply-To: <485B1C31.4020507@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Taku Izumi wrote:
> This patch makes e1000 driver ioport-free.
> This corrects behavior in probe function so as not to request ioport
> resources as long as they are not really needed. This is based on the
> ioport-free patch of e1000 driver from Auke Kok and Tomohiro Kusumi.
> 
> 
> Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> ---
>  drivers/net/e1000/e1000.h      |    4 +
>  drivers/net/e1000/e1000_main.c |   88 +++++++++++++++++++++++++++++++++++------
>  2 files changed, 80 insertions(+), 12 deletions(-)

ACK but failed to apply
