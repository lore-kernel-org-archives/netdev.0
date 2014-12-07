From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 1/6] net-PPP: Replacement of a printk() call by
 pr_warn() in mppe_rekey()
Date: Sun, 07 Dec 2014 04:42:10 -0800
Message-ID: <1417956130.31745.27.camel@perches.com>
References: <1417731809.2721.17.camel@perches.com>
	 <alpine.DEB.2.02.1412050820290.2059@localhost6.localdomain6>
	 <1417765287.2721.39.camel@perches.com>
	 <alpine.DEB.2.02.1412071140290.2044@localhost6.localdomain6>
	 <1417955413.31745.25.camel@perches.com>
	 <alpine.DEB.2.02.1412071335140.2030@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1412071335140.2030@localhost6.localdomain6>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-12-07 at 13:36 +0100, Julia Lawall wrote:
> the semantic patch is only using __func__ and only in cases where 
> the string wanted is similar to the name of the current function, so I 
> think it should be OK?

Yes, it'd be a good thing.


