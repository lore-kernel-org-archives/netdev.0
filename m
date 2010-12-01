From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Patch] bonding: clean up netpoll code
Date: Wed, 1 Dec 2010 08:14:57 -0800
Message-ID: <20101201081457.23102445@nehalam>
References: <20101201075043.5741.29172.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101201075043.5741.29172.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 1 Dec 2010 02:45:45 -0500
Amerigo Wang <amwang@redhat.com> wrote:

> +	if ((slave_dev->npinfo = bond_netpoll_info(bond))) {

Split assignment and conditional into two lines


-- 
