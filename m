From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 2/3] pci: bcm43xx avoid pci_find_device
Date: Mon, 05 Jun 2006 21:09:33 +0159
Message-ID: <44848184.5080102@gmail.com>
References: <20060526001053.D2349C7C58@atrey.karlin.mff.cuni.cz> <44764D4B.6050105@pobox.com> <4476D63E.8090207@gmail.com> <4476D6EC.4060501@pobox.com> <4476D95B.5030601@gmail.com> <4476DA5C.9080602@pobox.com> <4476DE47.7010907@gmail.com> <4476E203.1080701@pobox.com> <4476E69F.6020502@gmail.com> <20060605185614.GG6068@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:23734 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751302AbWFETJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 15:09:52 -0400
Received: by nf-out-0910.google.com with SMTP id c31so1847624nfb
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2006 12:09:51 -0700 (PDT)
To: Jiri Slaby <jirislaby@gmail.com>, Jeff Garzik <jgarzik@pobox.com>,
	Greg KH <gregkh@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	mb@bu3sch.de, st3@riseup.net
In-Reply-To: <20060605185614.GG6068@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville napsal(a):
> On Fri, May 26, 2006 at 01:29:12PM +0159, Jiri Slaby wrote:
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA1
>>
>> Jeff Garzik napsal(a):
>>> Jiri Slaby wrote:
>>>> -----BEGIN PGP SIGNED MESSAGE-----
>>>> Hash: SHA1
>>>>
>>>> Jeff Garzik napsal(a):
>>>>> The point is that you don't need to loop over the table,
>>>>> pci_match_one_device() does that for you.
>>>> The problem is, that there is no such function, I think.
>>>> If you take a look at pci_dev_present:
>>> The function you want is pci_dev_present().
>> Nope, it returns only 0/1.
> 
> Did we get a resolution on this?  I don't think Jeff is going to pull
> this patch from me until you satisfy him that it is correct... :-)
Yup: to use pci_get_device in some nice loop.
But unfortunately here is no time now, that's the problem, I'll post corrected
ones next month, sorry.

regards,
-- 
Jiri Slaby         www.fi.muni.cz/~xslaby
\_.-^-._   jirislaby@gmail.com   _.-^-._/
B67499670407CE62ACC8 22A032CC55C339D47A7E
