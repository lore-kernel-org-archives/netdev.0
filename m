From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH ethtool 5/5] ethtool: Add --version option
Date: Mon, 21 Feb 2011 22:16:24 -0800 (PST)
Message-ID: <1561212236.5138.1298355384916.JavaMail.root@tahiti.vyatta.com>
References: <1298315959.2608.73.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35082 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717Ab1BVGQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 01:16:25 -0500
In-Reply-To: <1298315959.2608.73.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> --- ethtool.8.in | 5 +++++
> ethtool.c | 6 ++++++
> 2 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/ethtool.8.in b/ethtool.8.in
> index 133825b..8b04335 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
> @@ -100,6 +100,8 @@ ethtool \- query or control network driver and
> hardware settings
> 
> .B ethtool \-h|\-\-help
> 
> +.B ethtool \-\-version
> + .B ethtool \-a|\-\-show\-pause
> .I ethX
> 
> @@ -310,6 +312,9 @@ settings of the specified device.
> .B \-h \-\-help
> Shows a short help message.
> .TP +.B \-\-version
> +Shows the ethtool version number.
> +.TP .B \-a \-\-show\-pause
> Queries the specified Ethernet device for pause parameter information.
> .TP diff --git a/ethtool.c b/ethtool.c
> index 32a97f6..e9cb2c9 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -115,6 +115,7 @@ static int do_permaddr(int fd, struct ifreq *ifr);
> static int send_ioctl(int fd, struct ifreq *ifr);
> 
> static enum {
> + MODE_VERSION = -2,
> MODE_HELP = -1,
> MODE_GSET=0, MODE_SSET,
> @@ -264,6 +265,7 @@ static struct option {
> { "-P", "--show-permaddr", MODE_PERMADDR,
> "Show permanent hardware address" },
> { "-h", "--help", MODE_HELP, "Show this help" },
> + { NULL, "--version", MODE_VERSION, "Show version number" },


The standard convention is to use -V for short form of version option.
