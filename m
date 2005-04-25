From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: NAPI, e100, and system performance problem
Date: Mon, 25 Apr 2005 08:16:19 -0400
Message-ID: <1114431379.7669.164.camel@localhost.localdomain>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	 <Pine.LNX.4.61.0504180943290.15052@linux.site>
	 <1113855967.7436.39.camel@localhost.localdomain>
	 <20050419055535.GA12211@sgi.com> <m1hdhzyrdz.fsf@muc.de>
	 <1114173195.7679.30.camel@localhost.localdomain>
	 <20050422172108.GA10598@muc.de>
	 <1114193902.7978.39.camel@localhost.localdomain>
	 <20050422183004.GC10598@muc.de>
	 <Pine.LNX.4.61.0504221131350.15052@linux.site>
	 <20050422115230.6037a362.davem@davemloft.net>
	 <Pine.LNX.4.61.0504241845070.2934@linux.site>
	 <1114429267.7669.160.camel@localhost.localdomain>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, ak@muc.de, gnb@sgi.com,
        jesse.brandeburg@intel.com, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <1114429267.7669.160.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


After looking closely at the data:
To reduce the work, 20 and 40% should be enough.
But lets rule out the tg3 and also test with e1000 and UDP.

cheers,
jamal

On Mon, 2005-25-04 at 07:41 -0400, jamal wrote:
> Actually, it may be sufficient to collect data for 20, 40, and 80% link
> utilization for napi, napi+dmiller_mchan and nonapi
> 
> Same for the e1000.
> 
> cheers,
> jamal
> 
