From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: Re: [take3 2/4] kevent: AIO, aio_sendfile() implementation.
Date: Thu, 03 Aug 2006 10:04:36 -0700
Message-ID: <44D22CA4.5090405@us.ibm.com>
References: <11545983603452@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932576AbWHCREp@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11545983603452@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> AIO, aio_sendfile() implementation.
>
> This patch includes asynchronous propagation of file's data into VFS
> cache and aio_sendfile() implementation.
> Network aio_sendfile() works lazily - it asynchronously populates pages
> into the VFS cache (which can be used for various tricks with adaptive
> readahead) and then uses usual ->sendfile() callback.
>
> ...
> --- /dev/null
> +++ b/kernel/kevent/kevent_aio.c
> @@ -0,0 +1,584 @@
> +/*
> + * 	kevent_aio.c
> + * 
>   
Since this is *almost* same as mpage.c code, wondering if its possible 
to make common
generic/helper routines in mpage.c and use it here ?

Thanks,
Badari
