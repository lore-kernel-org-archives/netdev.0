From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [flame^Wreview] net: netprio_cgroup: rework update socket logic
Date: Sun, 12 Aug 2012 23:23:59 -0700
Message-ID: <50289D7F.3070402@intel.com>
References: <20120813015348.GZ23464@ZenIV.linux.org.uk> <502896C5.7080303@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <502896C5.7080303@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> OK clearly I screwed it up thanks for reviewing Al. How about this.
>
>                  fdt = files_fdtable(files);
>                  for (fd = 0; fd < fdt->max_fds; fd++) {
>                          struct socket *sock;
>                          int err = 0;
>
>                          sock = sockfd_lookup(fd, &err);
>                          if (!sock) {
typo                           ^^^^^^
			   if (sock) {

to be honest I can't see why I didn't use sockfd_lookup in the first
place...
