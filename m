From: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Subject: Re: [PATCH] hostap: do not return positive number on failure path
 in prism2_open()
Date: Mon, 05 Aug 2013 08:01:08 +0400
Message-ID: <51FF2384.2070008@ispras.ru>
References: <1375672708-3017-1-git-send-email-khoroshilov@ispras.ru> <1375673616.3133.23.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <j@w1.fi>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375673616.3133.23.camel@joe-AO722>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/05/2013 07:33 AM, Joe Perches wrote:
> On Mon, 2013-08-05 at 07:18 +0400, Alexey Khoroshilov wrote:
>> prism2_open() as an .ndo_open handler should not return positive numbers
>> in case of failure, but it does return 1 in a couple of places.
>>
>> Found by Linux Driver Verification project (linuxtesting.org).
> How?
>
> http://linuxtesting.org/project/ldv
> http://linuxtesting.org/results/ldv
>
> Shows defects and patches to fix them, but not any script
> used to find it.
There is a link to build instructions there:
http://forge.ispras.ru/projects/ldv/wiki/Downloading_and_Building_LDV

Currently it requires some efforts to install all the dependencies, the
simplest way is to use puppet script for Ubuntu 12.04 that you can find
in the repository.

--
Alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
