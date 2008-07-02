From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [PATCH] Fix missing const in vortex_probe1() in the 3c59x driver
Date: Wed, 2 Jul 2008 13:32:09 +0200
Message-ID: <20080702113209.GA7469@bayes.mathematik.tu-chemnitz.de>
References: <20080627121220.23787.80724.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from john.hrz.tu-chemnitz.de ([134.109.132.2]:48241 "EHLO
	john.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753381AbYGBL7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 07:59:09 -0400
Content-Disposition: inline
In-Reply-To: <20080627121220.23787.80724.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2008 at 01:12:20PM +0100, David Howells wrote:
> In vortex_probe1() in the 3c59x driver, print_name should be made a const
> pointer to eliminate the following warning:
> 
> drivers/net/3c59x.c:1025: warning: assignment discards qualifiers from pointer target type
> 
> This is this line:
> 
> 			print_name = pci_name(pdev);
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

Thanks,

Steffen

> ---
> 
>  drivers/net/3c59x.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> 
> diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> index 2edda8c..5972114 100644
> --- a/drivers/net/3c59x.c
> +++ b/drivers/net/3c59x.c
> @@ -1010,7 +1010,7 @@ static int __devinit vortex_probe1(struct device *gendev,
>  	static int printed_version;
>  	int retval, print_info;
>  	struct vortex_chip_info * const vci = &vortex_info_tbl[chip_idx];
> -	char *print_name = "3c59x";
> +	const char *print_name = "3c59x";
>  	struct pci_dev *pdev = NULL;
>  	struct eisa_device *edev = NULL;
>  	DECLARE_MAC_BUF(mac);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
