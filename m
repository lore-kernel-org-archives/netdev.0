From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] xfrm audit hook misplaced in pfkey_delete and xfrm_del_sa
Date: Mon, 5 Mar 2007 19:37:43 -0500 (EST)
Message-ID: <Line.LNX.4.64.0703051937320.17389@d.namei>
References: <1172866536.31047.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Venkat Yekkirala <vyekkirala@trustedcs.com>,
	Stephen Smalley <sds@tycho.nsa.gov>
To: Eric Paris <eparis@parisplace.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933671AbXCFAht@vger.kernel.org>
In-Reply-To: <1172866536.31047.32.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Mar 2007, Eric Paris wrote:

> Inside pfkey_delete and xfrm_del_sa the audit hooks were not called if
> there was any permission/security failures in attempting to do the del
> operation (such as permission denied from security_xfrm_state_delete).
> This patch moves the audit hook to the exit path such that all failures
> (and successes) will actually get audited.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Acked-by: James Morris <jmorris@namei.org>


-- 
James Morris
<jmorris@namei.org>
