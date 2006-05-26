From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 2/3] pci: bcm43xx avoid pci_find_device
Date: Fri, 26 May 2006 13:29:12 +0159
Message-ID: <4476E69F.6020502@gmail.com>
References: <20060526001053.D2349C7C58@atrey.karlin.mff.cuni.cz> <44764D4B.6050105@pobox.com> <4476D63E.8090207@gmail.com> <4476D6EC.4060501@pobox.com> <4476D95B.5030601@gmail.com> <4476DA5C.9080602@pobox.com> <4476DE47.7010907@gmail.com> <4476E203.1080701@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	mb@bu3sch.de, st3@riseup.net, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:58135 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932324AbWEZLaG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 07:30:06 -0400
Received: by nf-out-0910.google.com with SMTP id h2so42209nfe
        for <netdev@vger.kernel.org>; Fri, 26 May 2006 04:30:05 -0700 (PDT)
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4476E203.1080701@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Jeff Garzik napsal(a):
> Jiri Slaby wrote:
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA1
>>
>> Jeff Garzik napsal(a):
>>> The point is that you don't need to loop over the table,
>>> pci_match_one_device() does that for you.
>> The problem is, that there is no such function, I think.
>> If you take a look at pci_dev_present:
> 
> The function you want is pci_dev_present().
Nope, it returns only 0/1.

regards,
- --
Jiri Slaby         www.fi.muni.cz/~xslaby
\_.-^-._   jirislaby@gmail.com   _.-^-._/
B67499670407CE62ACC8 22A032CC55C339D47A7E
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFEduafMsxVwznUen4RAjfzAKCaxRAK1nN5qx+akiA59E5Mq/ZPcgCffRwa
vwAz0SPClr6sCYy+DOjtilE=
=DHzA
-----END PGP SIGNATURE-----
