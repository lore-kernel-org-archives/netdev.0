From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] xen network backend driver
Date: Wed, 19 Jan 2011 19:31:41 +0000
Message-ID: <1295465501.3693.78.camel@localhost.localdomain>
References: <1295449318.14981.3484.camel@zakaz.uk.xensource.com>
	<1295455216.11126.39.camel@bwh-desktop>
	<1295459316.14981.3727.camel@zakaz.uk.xensource.com>
	<1295460304.11126.53.camel@bwh-desktop>  <4D3738AB.60701@goop.org>
	<1295465147.11126.57.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel <xen-devel@lists.xensource.com>, Konrad
	Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1295465147.11126.57.camel@bwh-desktop>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Wed, 2011-01-19 at 19:25 +0000, Ben Hutchings wrote: 
> If NAPI doesn't work for netback, with or without RPS, maybe you have to
> use that kthread.  But please don't reinvent the wheel by creating your
> own tasklets or require users to set a special parameter.

Agreed, the tasklets really should have been deprecated in favour of the
kthread long ago anyway and I should definitely have thought to nuke
them as part of the preparation for upstreaming.

Hopefully NAPI can be made to work for this case anyway.

Ian.
