From: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Subject: Re: [PATCH] ath: wil6210: Fix build error
Date: Mon, 22 Jul 2013 12:56:56 +0300
Message-ID: <458166038.k2AmqmisOp@lx-vladimir>
References: <1374374808-12768-1-git-send-email-Larry.Finger@lwfinger.net> <5330916.8NnOO4SNAp@lx-vladimir> <1374457543.16248.8.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: <thomas@fjellstrom.ca>, Larry Finger <Larry.Finger@lwfinger.net>,
	<linville@tuxdriver.com>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <wil6210@qca.qualcomm.com>,
	Stable <stable@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1374457543.16248.8.camel@deadeye.wl.decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, July 22, 2013 02:45:43 AM Ben Hutchings wrote:
> > ifeq (, $(findstring -W,$(EXTRA_CFLAGS)))
> >       subdir-ccflags-y += -Werror
> > endif
> 
> This is a pretty weird thing to do, and you've failed to account for
> -Wextra.
> 
> -Werror is generally a bad default in free software, as you have no
> control over which compiler version will be used.
> 

Well, you convinced me. I'll send patch removing -Werror.

Thanks, Vladimir
