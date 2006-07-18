From: Christian Borntraeger <borntrae@de.ibm.com>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Tue, 18 Jul 2006 13:16:18 +0200
Message-ID: <200607181316.18461.borntrae@de.ibm.com>
References: <20060718081625.GA13830@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:49723 "EHLO
	mtagate6.de.ibm.com") by vger.kernel.org with ESMTP id S932174AbWGRLQV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 07:16:21 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.7/8.13.7) with ESMTP id k6IBGJlq089736
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 18 Jul 2006 11:16:20 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6IBJOPG151060
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 18 Jul 2006 13:19:24 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6IBGJnw018323
	for <netdev@vger.kernel.org>; Tue, 18 Jul 2006 13:16:19 +0200
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060718081625.GA13830@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Evgeniy,

> +asmlinkage long sys_netchannel_control(void __user *arg)
[...]
> +	if (copy_from_user(&ctl, arg, sizeof(struct unetchannel_control)))
> +		return -ERESTARTSYS;
                        ^^^^^^^^^^^
[...]
> +	if (copy_to_user(arg, &ctl, sizeof(struct unetchannel_control)))
> +		return -ERESTARTSYS;
                        ^^^^^^^^^^^

I think this should be -EFAULT instead of -ERESTARTSYS, right?

--=20
Mit freundlichen Gr=FC=DFen / Best Regards

Christian Borntraeger
Linux Software Engineer zSeries Linux & Virtualization



