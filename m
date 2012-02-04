From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: network regression: cannot rename netdev twice
Date: Sat, 4 Feb 2012 00:14:57 -0200
Message-ID: <20120204021457.GA25386@khazad-dum.debian.net>
References: <4F27120A.4040106@suse.cz>
 <CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com>
 <4F27C54F.1010107@suse.cz>
 <CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jslaby@suse.cz>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Jan 2012, Kay Sievers wrote:
> Please make sure nothing tries to swap netif names in userspace. We
> have given up that approach, because it is far too fragile to
> temporary rename devices to be able to swap the names, and race
> against the loading of new kernel network drivers at the same time.

That's a damn fair reason, but the loss of that functionality could cause
trouble.  In fact, at first glance, to me it looks like this has a large
potential for unleashing untold pain and suffering in the sysadmin ranks
unless early userspace can emulate it somehow.

Is it possible to configure the kernel to use something other than "eth#" as
its initial namespace for netif names?  Or is there some other way to get
eth1 to be what you need eth1 to be during userland boot?

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
