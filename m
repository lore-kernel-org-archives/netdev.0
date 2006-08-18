From: "Joe Jin" <lkmaillist@gmail.com>
Subject: Re: [take10 1/2] kevent: Core files.
Date: Fri, 18 Aug 2006 17:35:45 +0800
Message-ID: <215036450608180235l28836e3fpa2b529d7c0f69571@mail.gmail.com>
References: <11557316922047@2ka.mipt.ru> <11557316932803@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Ulrich Drepper" <drepper@redhat.com>,
	"Andrew Morton" <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	"Zach Brown" <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:32487 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751321AbWHRJfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 05:35:46 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1227944nfa
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 02:35:45 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <11557316932803@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static int __devinit kevent_user_init(void)
> +{
> +       int err = 0;
> +
> +       err = kevent_sys_init();
> +       if (err)
> +               panic("%s: failed to initialize kevent: err=%d.\n", err);

Here should be?
                    panic("%s: failed to initialize kevent: err=%d\n",
kevent_name, err);
