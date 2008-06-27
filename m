From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] e1000e: make ioport free
Date: Fri, 27 Jun 2008 02:08:43 -0400
Message-ID: <486483EB.9080207@garzik.org>
References: <485B1B8E.1060108@jp.fujitsu.com> <485B1C7E.90203@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>,
	auke-jan.h.kok@intel.com
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758375AbYF0GKI@vger.kernel.org>
In-Reply-To: <485B1C7E.90203@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Taku Izumi wrote:
> This patch makes e1000e driver ioport-free.
> This corrects behavior in probe function so as not to request ioport
> resources as long as they are not really needed.
> 
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> ---
>  drivers/net/e1000e/e1000.h  |    4 +++
>  drivers/net/e1000e/netdev.c |   48 ++++++++++++++++++++++++++++++++++++++------
>  2 files changed, 46 insertions(+), 6 deletions(-)

applied 2-3
