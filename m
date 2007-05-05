From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 8/11][TG3]: Add TG3_FLAG_SUPPORT_MSI flag.
Date: Fri, 04 May 2007 20:38:43 -0400
Message-ID: <463BD213.2070004@garzik.org>
References: <1178326494.4859.24.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53234 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423688AbXEEAiq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:38:46 -0400
In-Reply-To: <1178326494.4859.24.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> @@ -10404,6 +10400,8 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
>  	}
>  }
>  
> +static struct pci_dev * __devinit tg3_find_peer(struct tg3 *);
> +
>  static int __devinit tg3_get_invariants(struct tg3 *tp)
>  {
>  	static struct pci_device_id write_reorder_chipsets[] = {


Prototypes are better kept at the top of the file, grouped together.  It 
can sometimes be a pain later on, if they are scattered throughout a big 
source file like tg3.c.

ACK the patch's content of course

