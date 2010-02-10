From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] Allow change timing values to wait slow devices
 bring up before try register an interface to IP-Config
Date: Tue, 09 Feb 2010 23:01:04 -0800 (PST)
Message-ID: <20100209.230104.180816804.davem@davemloft.net>
References: <600adaf51002091944t25a36090s5cb002098c201fc6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tiago.maluta@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <600adaf51002091944t25a36090s5cb002098c201fc6@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tiago Maluta <tiago.maluta@gmail.com>
Date: Wed, 10 Feb 2010 03:44:50 +0000

> I had some problems with 'slow' net devices when ic_open_devs() try to
> search for interfaces before they are registered. The solution was
> change some timing values. I propose this patch to allow user change
> this on menuconfig.

First, please use plain text attachments when posting patches.

Second, please use netdev@vger.kernel.org for reaching the
networking developers.  linux-net is for user questions only.

Lastly, others have hit this issue before, and config options
and kernel command line options are prone to failure and
hard for casual users to discover.  For one example thread
on this topic see:

http://marc.info/?l=linux-netdev&m=126319430325919&w=2

Better is just to change the defaults to higher values and
I'd like to hear some suggestions from people hitting this issue.

Thanks.
