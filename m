From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 2/3] pci: bcm43xx avoid pci_find_device
Date: Fri, 26 May 2006 13:51:28 +0159
Message-ID: <4476EBD7.3060506@gmail.com>
References: <20060526001053.D2349C7C58@atrey.karlin.mff.cuni.cz> <4476D6EC.4060501@pobox.com> <4476D95B.5030601@gmail.com> <200605261349.56011.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Greg KH <gregkh@suse.de>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
        st3@riseup.net, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:19529 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932355AbWEZLwQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 07:52:16 -0400
Received: by nf-out-0910.google.com with SMTP id h2so45234nfe
        for <netdev@vger.kernel.org>; Fri, 26 May 2006 04:52:15 -0700 (PDT)
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200605261349.56011.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Michael Buesch napsal(a):
> On Friday 26 May 2006 12:33, you wrote:
>>>>>> --- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>>>>>> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>>>>>> @@ -2131,6 +2131,13 @@ out:
>>>>>>      return err;
>>>>>>  }
>>>>>>
>>>>>> +#ifdef CONFIG_BCM947XX
>>>>>> +static struct pci_device_id bcm43xx_ids[] = {
> 
> Call it
> static struct pci_device_id bcm43xx_47xx_ids[] = {
> please.
> 
> And; _important_; if you submit this change, _also_
> do a patch against the devicescape version of the driver in
> John Linville's wireless-dev tree
> drivers/net/wireless/d80211/bcm43xx
> in the tree at git://kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git
Ok, thanks.

- --
Jiri Slaby         www.fi.muni.cz/~xslaby
\_.-^-._   jirislaby@gmail.com   _.-^-._/
B67499670407CE62ACC8 22A032CC55C339D47A7E
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFEduvXMsxVwznUen4RAqQcAJ9j870AGMn5jXW68tEQHZXltAenmQCfX9Ik
oyRfuNnKxGHu8HGVvcDVJHM=
=/NUD
-----END PGP SIGNATURE-----
