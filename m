From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3 4/7] ethtool: cosmetic: Use ethtool ethtool_cmd_speed
 API
Date: Thu, 28 Apr 2011 03:12:54 +0100
Message-ID: <1303956774.3032.427.camel@localhost>
References: <1303954043-17440-1-git-send-email-decot@google.com>
	 <1303954043-17440-5-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, mirq-linux@rere.qmqm.pl,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Decotigny <decot@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303954043-17440-5-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-04-27 at 18:27 -0700, David Decotigny wrote:
> This updates the network drivers so that they don't access the
> ethtool_cmd::speed field directly, but use ethtoo_cmd_speed() instead.
> 
> For most drivers, these changes are purely cosmetic and don't
> fix any problem, such as for those 1GbE/10GbE drivers that indirectly
> call their own ethtool get_settings()/mii_ethtool_gset(). The changes
> are meant to enforce code consistency and provide robustness with
> future larger throughputs, at the expense of a few CPU cycles for each
> ethtool operation.
> 
> All the drivers compiled with make allyesconfig ion x86_64 have been
> updated.
> 
> Tested: make allyesconfig on x86_64 + e1000e/bnx2x work
> Signed-off-by: David Decotigny <decot@google.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
