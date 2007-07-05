From: Joel Becker <Joel.Becker@oracle.com>
Subject: Re: [PATCH -mm 5/9] netconsole: Introduce dev_status member
Date: Wed, 4 Jul 2007 23:39:05 -0700
Message-ID: <20070705063904.GG17650@tasint.org>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in> <20070704110804.28520.25792.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>, Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758131AbXGEGj7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070704110804.28520.25792.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 04, 2007 at 04:38:04PM +0530, Satyam Sharma wrote:
> -	if (!(event == NETDEV_CHANGEADDR || event == NETDEV_CHANGENAME))
> -		goto done;
> +	if (!(event == NETDEV_UP || event == NETDEV_DOWN ||
> +	      event == NETDEV_CHANGEADDR || event == NETDEV_CHANGENAME))
> +	      	goto done;
>
>  	if (nt->np.dev == dev) {
>  		switch (event) {

	It's a small nit, but isn't the large if() just the degenerate
default case of the switch()?  Why have it at all?  

Joel

-- 

Life's Little Instruction Book #396

	"Never give anyone a fruitcake."

Joel Becker
Principal Software Developer
Oracle
E-mail: joel.becker@oracle.com
Phone: (650) 506-8127
