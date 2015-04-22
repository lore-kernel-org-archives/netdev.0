From: Hyong-Youb Kim <hkim@cspi.com>
Subject: Re: [PATCH v3] ethernet: myri10ge: use arch_phys_wc_add()
Date: Wed, 22 Apr 2015 16:15:21 +0900
Message-ID: <20150422071521.GA1500@hykim-PC>
References: <1429646986-16686-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <hykim@myri.com>, <netdev@vger.kernel.org>, <luto@amacapital.net>,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	Suresh Siddha <sbsiddha@gmail.com>,
	"Ingo Molnar" <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	Juergen Gross <jgross@suse.com>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Dave Airlie <airlied@redhat.com>,
	Antonino Daplas <adaplas@gmail.com>,
	"Jean-Christophe Plagniol-Villard" <plagnioj@jcrosoft.com>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>,
	<linux-kernel@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1429646986-16686-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 21, 2015 at 01:09:45PM -0700, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> This driver already uses ioremap_wc() on the same range
> so when write-combining is available that will be used
> instead.
[...]
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>

Tested using the patched v4.0.  It works fine.  Thanks.
