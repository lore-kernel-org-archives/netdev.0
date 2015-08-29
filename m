From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next] openvswitch: Fix conntrack compilation without
 mark.
Date: Sat, 29 Aug 2015 11:38:20 +0900
Message-ID: <20150829023817.GB23659@vergenet.net>
References: <1440814931-29059-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1440814931-29059-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 28, 2015 at 07:22:11PM -0700, Joe Stringer wrote:
> Fix build with !CONFIG_NF_CONNTRACK_MARK && CONFIG_OPENVSWITCH_CONNTRACK
> 
> Fixes: 182e304 ("openvswitch: Allow matching on conntrack mark")
> Reported-by: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Thanks Joe,

this seems to solve the build problem that I observed.

Tested-by: Simon Horman <simon.horman@netronome.com>
